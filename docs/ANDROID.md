# Adrytentaciones para Android

## Compilar

Se necesita Flutter 3.47.7 (Dart 3.13.5), un JDK 17 completo y el Android SDK
con la plataforma 36, Build Tools 36 y NDK 28.2.13676358. Desde la raíz del
repositorio:

```sh
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`. El identificador
del paquete es `com.adrytentaciones.presupuestos`. El manifiesto de release no
solicita permiso de internet. El código fuente y los recursos están en `lib/`,
`assets/fonts/` y `android/`; la aplicación web anterior permanece como
referencia.

### Firma

Sin `android/key.properties`, Gradle firma el APK de aceptación con la clave de
depuración local. Sirve para instalarlo y probarlo en el teléfono, pero no para
distribuir actualizaciones duraderas. Para una entrega definitiva, el dueño debe
guardar una clave de firma propia fuera del repositorio y crear
`android/key.properties` con:

```properties
storeFile=C:/ruta/segura/adrytentaciones-release.jks
storePassword=...
keyAlias=adrytentaciones
keyPassword=...
```

Luego se repite `flutter build apk --release`. No se deben subir la clave ni
`key.properties` al repositorio. Hay que conservarlos para firmar futuras
actualizaciones con el mismo identificador de paquete.

## Instalar y probar

Se puede copiar el APK al teléfono y abrirlo desde Archivos, autorizando la
instalación desde esa fuente si Android lo solicita. Con depuración USB activada,
también se puede usar:

```sh
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

Si una versión previa del mismo paquete se firmó con otra clave, Android no
permite actualizarla directamente; se debe desinstalar la versión anterior.
La app no guarda presupuestos, por lo que esa desinstalación no elimina un
historial dentro de ella.

## Uso

1. Abrí Adrytentaciones y cargá nombre, fechas y al menos un producto.
2. Escribí cantidades enteras y precios en pesos, por ejemplo `45.000,50`.
3. Revisá subtotales, descuento y total. Tocá **Vista previa**.
4. Si aparece un error, corregí el campo indicado; los datos escritos quedan
   en el formulario.
5. En la vista previa, tocá **Compartir o guardar PDF** y elegí una aplicación
   o la opción de guardado de Android. **Editar presupuesto** vuelve al formulario.

El PDF se calcula en el teléfono solo al tocar esa acción. La app no conserva
presupuestos ni borradores al iniciar una nueva sesión. Los archivos temporales
usados por el menú de compartir se limpian al iniciar una sesión nueva.

## Aceptación en el teléfono

El APK de aceptación se instaló en un Motorola edge 70 pro con Android 16. Con
modo avión activo se cargaron dos productos y un descuento; el formulario y la
vista previa mostraron subtotal `$ 63.000,00` y total `$ 58.000,00`. Se guardó
`presupuesto-carolina-perez.pdf` en Descargas y se abrió en el visor PDF del
teléfono. Una nueva apertura de la app mostró el formulario vacío. La pantalla
también se revisó en un emulador de 320 píxeles lógicos. Se restauró la conexión
del teléfono al terminar.

Falta la revisión y aceptación de la dueña del APK y del PDF. Railway seguirá
activo hasta contar con esa aceptación y con aprobación separada para retirar
el servicio exacto.
