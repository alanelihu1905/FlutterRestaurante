# Sistema de Pedidos para Restaurante — Guía rápida

## Resumen
Repositorio monorepo Flutter con tres paquetes:
- `shared_logic/` — modelos y lógica compartida (servicios, repositorios).
- `client_app/` — aplicación del cliente (pedidos).
- `admin_app/` — aplicación de administración/cocina.

## Requisitos
- Flutter instalado (ejecutar `flutter doctor` y resolver advertencias).
- Emulador o dispositivo Android/iOS conectado.
- (Opcional) Cuenta de Firebase y Cloud Firestore si la app lo requiere en tu configuración.

## Estructura del proyecto
- shared_logic/
    - `lib/models/` — definiciones de modelos (Product, Order, ...).
    - `lib/services/` — `order_repository.dart` y servicios compartidos.
- client_app/
    - `lib/viewmodels/` — ChangeNotifiers usados por la UI.
    - `lib/views/` — pantallas y widgets.
    - `android/`, `ios/` — configuración nativa por app.
- admin_app/ — estructura equivalente para la app de administración.


## Instalar dependencias
Desde la raíz del repo:
- `cd shared_logic && flutter pub get`
- `cd ../client_app && flutter pub get`
- `cd ../admin_app && flutter pub get`

Si editas `shared_logic`, vuelve a ejecutar `flutter pub get` en cada app que lo use.

## Ejecutar (desarrollo)
Cliente:
- `cd client_app`
- `flutter run -d <device-id>`

Administrador:
- `cd admin_app`
- `flutter run -d <device-id>`

Flujos típicos:
- Cliente: ingresar nombre → ver menú → agregar productos → carrito → confirmar pedido.
- Admin: ver dashboard, cocina (Pendiente / En preparación / Listo), editar menú.

## Demo local (rápido)
1. Abrir `client_app` en un dispositivo/emulador.
2. Abrir `admin_app` en otro dispositivo/emulador.
3. Crear pedido desde el cliente.
4. Ver la orden en la app admin y cambiar estados (Pendiente → En preparación → Listo).
5. Ver actualización de estado en la app cliente.

## Desarrollo y convenciones
- Estado: `provider` + `ChangeNotifier`. ViewModels en `lib/viewmodels/` y registrados en `main.dart` vía `MultiProvider`.
- Servicio compartido: instanciar `OrderRepository()` en `main.dart` y pasarlo con `Provider<OrderRepository>.value(...)`.
- Prefiere streams expuestos por el repositorio (`watchProducts()`, `watchOrders()`) para actualizar UI.

## Tests y builds
- Tests:
    - `cd client_app && flutter test`
    - `cd admin_app && flutter test`
    - `cd shared_logic && flutter test`
- Builds:
    - Android APK: `cd client_app && flutter build apk`

## Consejos rápidos
- Mantén `shared_logic` como dependencia por path; actualizar su API puede requerir cambios en ambas apps.
- Ejecuta `flutter pub get` en las apps después de modificar `shared_logic`.
- Usa los streams del `OrderRepository` para evitar polling manual.

Si quieres, puedo generar un README en inglés, añadir ejemplos de configuración de Firebase paso a paso o incluir un diagrama simple del flujo de datos.  