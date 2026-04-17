# Instrucciones - Sistema de Verificación de Email

## Pasos para completar la configuración

### 1. Instalar dependencias
```bash
bundle install
```

### 2. Ejecutar migración
```bash
rails db:migrate
```

### 3. Configurar credenciales SMTP (Brevo)
Crea/actualiza el archivo `.env` con las credenciales de Brevo:
```bash
# SMTP Configuration (Brevo)
SMTP_ADDRESS=smtp-relay.brevo.com
SMTP_PORT=587
SMTP_USERNAME=tu_api_key_de_brevo
SMTP_PASSWORD=tu_smtp_password
SMTP_DOMAIN=iyaiclub.com
```

### 4. Reiniciar el servidor
```bash
rails server
```

## Flujo de prueba en desarrollo

1. **Registrar un nuevo usuario**
   - Ve a `/users/sign_up`
   - Completa el formulario
   - Se abrirá automáticamente el email en el navegador (letter_opener)

2. **Confirmar la cuenta**
   - Haz clic en "Confirmar mi cuenta" en el email
   - Serás redirigido al dashboard según tu rol
   - Recibirás un segundo email de bienvenida

3. **Verificar el flujo**
   - Intenta iniciar sesión sin confirmar (debería bloquear)
   - Confirma la cuenta y verifica que puedas iniciar sesión

## Archivos modificados/creados

### Modelos
- `app/models/user.rb` - Agregado `:confirmable` y callback de bienvenida

### Controladores
- `app/controllers/users/confirmations_controller.rb` - Controlador personalizado de confirmaciones

### Mailers
- `app/mailers/application_mailer.rb` - Actualizado con correo corporativo y logo adjunto
- `app/mailers/user_mailer.rb` - Mailer para correo de bienvenida

### Vistas
- `app/views/layouts/mailer.html.erb` - Layout corporativo responsive con logo y animaciones
- `app/views/devise/mailer/confirmation_instructions.html.erb` - Plantilla de confirmación con diseño atractivo
- `app/views/user_mailer/welcome_email.html.erb` - Plantilla de bienvenida con elementos visuales

### Configuración
- `config/initializers/devise.rb` - Configuración de confirmación
- `config/environments/development.rb` - Letter opener
- `config/environments/production.rb` - SMTP con variables de entorno

### Migraciones
- `db/migrate/20260408150000_add_confirmable_to_users.rb` - Campos de confirmación

## Configuración de producción

1. **Configurar variables de entorno** en el VPS:
```bash
export SMTP_ADDRESS=smtp-relay.brevo.com
export SMTP_PORT=587
export SMTP_USERNAME=tu_api_key
export SMTP_PASSWORD=tu_smtp_password
export SMTP_DOMAIN=iyaiclub.com
```

2. **Verificar dominio en Brevo** (ya está hecho)

3. **Probar envío de emails** en producción

## Correos disponibles

- **info@iyaiclub.com** - Correos generales y confirmación
- **reservas@iyaiclub.com** - Notificaciones de reservas
- **pauliyai@iyaiclub.com** - Soporte técnico
- **portal@iyaiclub.com** - Portal de membresías

## Características implementadas:

- **Verificación de email obligatoria** (no se puede iniciar sesión sin confirmar)
- **Correo de bienvenida automático** (después de confirmar)
- **Diseño corporativo responsive** (mobile-first) con:
  - Logo de IyaiClub incrustado
  - Paleta de colores corporativa (#34c759, #c0aa40, #ff9500)
  - Animaciones sutiles y efectos hover
  - Iconos de FontAwesome
  - Gradients y sombras modernas
- **Múltiples remitentes** (info@, reservas@, pauliyai@, portal@)
- **Configuración por entorno** (development con letter_opener, production con SMTP)
- **Seguridad** (tokens con expiración, reconfirmación de cambios)
- **Mensajes en español** y personalizados
- **Elementos visuales atractivos**:
  - Feature boxes con gradientes
  - Botones con efectos hover
  - Sección de redes sociales
  - Grid layouts responsive
  - Iconos temáticos de viaje

## Seguridad

- Tokens de confirmación expiran en 3 días
- Usuarios no pueden iniciar sesión sin confirmar
- Emails de cambio también requieren confirmación
- HTTPS obligatorio en producción (ya configurado)

## Solución de problemas

### Email no llega en producción
1. Verificar credenciales SMTP
2. Revisar logs: `tail -f log/production.log`
3. Verificar que el dominio esté autenticado en Brevo

### No se puede iniciar sesión
1. Verificar que `confirmed_at` no sea nulo
2. Reenviar email de confirmación desde `/users/confirmation/new`

### Letter opener no funciona
1. Verificar que esté en `development.rb`
2. Reiniciar el servidor
3. Verificar que el email se esté enviando (revisar logs)
