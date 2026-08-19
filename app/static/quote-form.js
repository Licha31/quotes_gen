(() => {
  const itemList = document.querySelector("#item-list");
  const addItemButton = document.querySelector("#add-item");
  const discountInput = document.querySelector("#discount");
  const quoteSubtotal = document.querySelector("[data-quote-subtotal]");
  const quoteDiscount = document.querySelector("[data-quote-discount]");
  const quoteTotal = document.querySelector("[data-quote-total]");

  if (
    !itemList ||
    !addItemButton ||
    !discountInput ||
    !quoteSubtotal ||
    !quoteDiscount ||
    !quoteTotal
  ) {
    return;
  }

  const parseCentavos = (rawValue) => {
    let value = rawValue.replaceAll("$", "").replaceAll(" ", "").trim();
    if (!value) {
      return null;
    }

    let sign = 1n;
    if (value.startsWith("-")) {
      sign = -1n;
      value = value.slice(1);
    }
    if (!value) {
      return null;
    }

    let whole;
    let decimals;
    if (value.includes(",")) {
      if (value.split(",").length !== 2) {
        return null;
      }
      [whole, decimals] = value.split(",");
      whole = whole.replaceAll(".", "");
    } else if (value.includes(".")) {
      const groups = value.split(".");
      if (groups.length > 2 || (groups.length === 2 && groups[1].length === 3)) {
        whole = groups.join("");
        decimals = "";
      } else {
        [whole, decimals] = groups;
      }
    } else {
      whole = value;
      decimals = "";
    }

    if (!/^\d+$/.test(whole) || (decimals && !/^\d{1,2}$/.test(decimals))) {
      return null;
    }

    const decimalDigits = `${decimals}00`.slice(0, 2);
    return sign * (BigInt(whole) * 100n + BigInt(decimalDigits));
  };

  const formatCentavos = (centavos) => {
    const isNegative = centavos < 0n;
    const absoluteValue = isNegative ? -centavos : centavos;
    const pesos = absoluteValue / 100n;
    const decimalDigits = (absoluteValue % 100n).toString().padStart(2, "0");
    const groupedPesos = pesos
      .toString()
      .replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    return `${isNegative ? "− " : ""}$ ${groupedPesos},${decimalDigits}`;
  };

  const rowSubtotal = (row) => {
    const quantityInput = row.querySelector('[name="item_quantity"]');
    const priceInput = row.querySelector('[name="item_unit_price"]');
    const quantityValue = quantityInput?.value.trim() ?? "";
    const unitPrice = parseCentavos(priceInput?.value ?? "");

    if (!/^\d+$/.test(quantityValue) || unitPrice === null || unitPrice < 0n) {
      return 0n;
    }

    const quantity = BigInt(quantityValue);
    return quantity > 0n ? quantity * unitPrice : 0n;
  };

  const updateTotals = () => {
    let subtotal = 0n;
    itemList.querySelectorAll("[data-item-row]").forEach((row) => {
      const itemSubtotal = rowSubtotal(row);
      subtotal += itemSubtotal;
      const output = row.querySelector("[data-item-subtotal]");
      if (output) {
        output.textContent = formatCentavos(itemSubtotal);
      }
    });

    const parsedDiscount = parseCentavos(discountInput.value);
    const discount = parsedDiscount !== null && parsedDiscount >= 0n ? parsedDiscount : 0n;
    quoteSubtotal.textContent = formatCentavos(subtotal);
    quoteDiscount.textContent = `− ${formatCentavos(discount)}`;
    quoteTotal.textContent = formatCentavos(subtotal - discount);
  };

  const updateInputIdentity = (row, inputName, idPrefix, index) => {
    const input = row.querySelector(`[name="${inputName}"]`);
    const label = input?.closest(".field")?.querySelector("label");
    if (!input || !label) {
      return;
    }

    input.id = `${idPrefix}-${index}`;
    label.htmlFor = input.id;

    const error = input.closest(".field")?.querySelector(".field__error");
    if (error) {
      error.id = `${idPrefix}-error-${index}`;
      input.setAttribute("aria-describedby", error.id);
    }
  };

  const renumberRows = () => {
    const rows = [...itemList.querySelectorAll("[data-item-row]")];
    rows.forEach((row, index) => {
      const heading = row.querySelector("h3");
      const itemNumber = row.querySelector("[data-item-number]");
      const removeButton = row.querySelector(".item-remove");

      if (heading) {
        heading.id = `item-heading-${index}`;
        row.setAttribute("aria-labelledby", heading.id);
      }
      if (itemNumber) {
        itemNumber.textContent = String(index + 1);
      }
      if (removeButton) {
        removeButton.hidden = rows.length === 1;
      }

      updateInputIdentity(row, "item_description", "item-description", index);
      updateInputIdentity(row, "item_quantity", "item-quantity", index);
      updateInputIdentity(row, "item_unit_price", "item-price", index);

      const output = row.querySelector("[data-item-subtotal]");
      if (output) {
        output.setAttribute("for", `item-quantity-${index} item-price-${index}`);
      }
    });
  };

  const clearClonedRow = (row) => {
    row.querySelectorAll(".field__error").forEach((error) => error.remove());
    row.querySelectorAll('[aria-invalid="true"]').forEach((input) => {
      input.removeAttribute("aria-invalid");
      input.removeAttribute("aria-describedby");
    });
    row
      .querySelectorAll(".money-input--error")
      .forEach((wrapper) => wrapper.classList.remove("money-input--error"));

    const description = row.querySelector('[name="item_description"]');
    const quantity = row.querySelector('[name="item_quantity"]');
    const unitPrice = row.querySelector('[name="item_unit_price"]');
    const subtotal = row.querySelector("[data-item-subtotal]");

    if (description) description.value = "";
    if (quantity) quantity.value = "1";
    if (unitPrice) unitPrice.value = "";
    if (subtotal) subtotal.textContent = formatCentavos(0n);
  };

  addItemButton.addEventListener("click", () => {
    const sourceRow = itemList.querySelector("[data-item-row]");
    if (!sourceRow) {
      return;
    }

    const newRow = sourceRow.cloneNode(true);
    clearClonedRow(newRow);
    itemList.append(newRow);
    renumberRows();
    updateTotals();
    newRow.querySelector('[name="item_description"]')?.focus();
  });

  itemList.addEventListener("click", (event) => {
    const removeButton = event.target.closest(".item-remove");
    if (!removeButton || itemList.querySelectorAll("[data-item-row]").length === 1) {
      return;
    }

    removeButton.closest("[data-item-row]")?.remove();
    renumberRows();
    updateTotals();
  });

  itemList.addEventListener("input", updateTotals);
  discountInput.addEventListener("input", updateTotals);

  renumberRows();
  updateTotals();
})();
