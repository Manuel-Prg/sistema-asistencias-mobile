# 📱 Sistema de Asistencia — App Móvil Alumnos (Android & iOS)

> Versión móvil nativa para estudiantes de Servicio Social, Prácticas Profesionales y Convenio Dual de la **Casa Universitaria del Agua**.

---

## 📌 Contexto de la Migración

El sistema web original (`sistema-asistencia`) administra tanto el rol de **Supervisores** como el de **Alumnos**. Siguiendo la directiva de arquitectura:
- 💻 **Supervisores:** Se mantiene 100% en la plataforma Web para monitoreo administrativo, control de salas, cierres forzados, auditoría de asistencia y justificación de faltas/retardos.
- 📱 **Alumnos:** Se migra a esta aplicación móvil nativa (**Flutter + Riverpod + Supabase**) optimizada para **Android** e **iOS**, diseñada para registrar entradas y salidas en el recinto sin fricción y en pocos segundos.

---

## 🚀 Características Migradas (Rol Alumno)

### 1. 🔐 Autenticación y Verificación de Rol
- Login seguro con correo y contraseña vía **Supabase Auth**.
- **Filtro Estricto de Rol:** Si un usuario con rol de Supervisor intenta ingresar en la app móvil, el sistema deniega el acceso y le indica que continúe en la versión Web.
- **Recuperación de Contraseña:** Flujo integrado para enviar correos de restablecimiento.
- **Panel de Estudiantes Activos en Vivo:** Visualización en tiempo real de quiénes se encuentran actualmente en el recinto antes o después de autenticarse.

### 2. 📍 Registro de Asistencia (Check-in & Check-out)
- **Salas autorizadas:** `Sala 1`, `Sala 2`, `Sala 2 y Galería`, `Sala 3`, `Sala 4`, `Sala 4 y 5`, `Todas` y `Site`.
- **Turnos:** `Matutino` (11:00 - 14:00) y `Vespertino` (14:00 - 18:00).
- **Validación de Sesión Activa:** Auto-cierre de sesiones obsoletas (>24 horas) y prevención de doble entrada.
- **Detección Automática de Retardos:** Compara la hora actual de entrada contra el horario configurado por el alumno en "Tu Horario" para ese día. Si excede los **15 minutos de tolerancia**, se marca `is_late: true`, calcula los minutos tarde y muestra la alerta correspondiente.
- **Salida Anticipada (<3 horas):** Diálogo obligatorio para justificar el motivo (`Enfermedad`, `Imprevisto personal`, `Emergencia familiar` u `Otra razón`) preservando la auditoría reglamentaria.
- **Límites de Jornada:** Tope de 10 horas normales y 20 horas en eventos.

### 3. 📅 Sección "Tu Horario" (`/student/schedule`)
- Configuración personalizada de días de asistencia (Martes a Domingo) y horarios de entrada/salida pactados.
- Base oficial para el cálculo de retardos en tiempo real.

### 4. 🌟 Eventos Especiales (`/student/eventos`)
- Módulo de entrada a eventos autorizados con **acreditación de horas al doble (2x)**.

### 5. 🛡️ Control de Puntualidad, Retardos y Faltas Injustificadas
- **Regla 3:1:** Cada 3 retardos sin justificar equivalen a 1 falta injustificada.
- **Alerta de Baja:** Acumular 3 faltas injustificadas enciende el banner crítico de riesgo de baja administrativa.
- **Personalidad Nuty / Skippy ("El Asistente Impertinente"):** Mensajes y citas satíricas deterministas según el expediente y tipo de programa del alumno.

### 6. 🟩 Gráfica de Actividad de 16 Semanas (Heatmap Estilo GitHub)
- Cuadrícula interactiva con scroll horizontal que mapea los últimos 112 días:
  - 🟢 **Verde:** Asistencia puntual a tiempo.
  - 🔴 **Rojo Opaco:** Días con retardo sin justificar.
  - 🚨 **Rojo Brillante:** Días con falta injustificada.
  - 🔵 **Azul:** Días con justificación autorizada.
  - ⚪ **Gris:** Días sin registro.
- Tocar cualquier casilla abre el desglose completo de registros del día.

### 7. 📊 Avance de Horas y Celebración de Libertad
- Progreso porcentual y horas restantes según el tipo de programa (`Servicio Social: 480h`, `Prácticas: 240h/480h`, `Convenio Dual`).
- **Celebración de Fin de Horas:** Al llegar al 100%, se activa la animación de confeti y el mensaje final de Nuty felicitando al estudiante.

### 8. 🎨 Diseño e Identidad Institucional
- Basado en el Design System oficial **"Canales de Cantera y Espejo de Agua"**:
  - Azul Estanque (`#0C3C4C`), Piedra Caliza (`#F4F1EA`), Bloques de Sillar (`#FAF8F3`), Terracota (`#B84A27`) y Señal Aqua (`#5EEAD4`).
  - Soporte completo para **Modo Claro** y **Modo Oscuro**.
  - Accesibilidad WCAG 2.2 AA (objetivos táctiles ≥ 48dp).

---

## 🛠️ Estructura del Código

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart        # Paleta oficial (Cantera, Estanque, Terracota)
│   │   ├── app_constants.dart     # Salas, turnos, tolerancias, motivos
│   │   └── supabase_config.dart   # URL y llaves de Supabase
│   ├── theme/
│   │   └── app_theme.dart         # Temas Claro y Oscuro con tipografía institucional
│   └── utils/
│       ├── date_utils.dart        # Formateo de fechas y horas en es_MX
│       └── skippy_quotes.dart     # Citas deterministas de Nuty y alertas
├── models/
│   ├── active_student.dart        # Modelo de estudiantes activos en recinto
│   ├── attendance_record.dart     # Modelo de registros de asistencia
│   ├── infraction_models.dart     # Modelos de cálculo de infracciones y heatmap
│   ├── profile.dart               # Perfil de usuario (rol, nombre, tutor)
│   ├── student.dart               # Horas requeridas, acumuladas y modalidad
│   └── student_schedule.dart      # Horarios semanales del alumno
├── providers/
│   ├── auth_provider.dart         # Estado de autenticación y verificación de rol
│   ├── student_provider.dart      # Dashboard, check-in, check-out, historial
│   ├── schedule_provider.dart     # Gestión de "Tu Horario"
│   └── theme_provider.dart        # Persistencia de Modo Claro / Oscuro
├── services/
│   ├── infraction_service.dart    # Lógica de retardos, 3:1 y matriz de 16 semanas
│   └── supabase_service.dart      # Conexión directa a Supabase (Postgres & Auth)
├── views/
│   ├── auth/
│   │   ├── login_view.dart        # Inicio de sesión con activos en recinto
│   │   └── forgot_password_view.dart # Recuperación de contraseña
│   ├── navigation/
│   │   └── main_navigation_view.dart # Barra de navegación inferior
│   └── student/
│       ├── dashboard_view.dart    # Vista principal del estudiante
│       ├── schedule_view.dart     # Vista "Tu Horario"
│       ├── events_view.dart       # Registro a eventos de horas dobles
│       ├── resources_view.dart    # Reglamentos y lineamientos
│       ├── profile_view.dart      # Perfil académico y ajustes
│       └── widgets/
│           ├── active_students_sheet.dart
│           ├── attendance_heatmap_card.dart
│           ├── attendance_history_list.dart
│           ├── check_in_out_card.dart
│           ├── early_departure_dialog.dart
│           ├── freedom_dialog.dart
│           └── progress_card.dart
└── main.dart                      # Inicialización de Supabase, Localización y Riverpod
```

---

## 📱 Cómo Ejecutar la Aplicación

### Requisitos Previos
- **Flutter SDK** (3.47+ o superior) instalado.
- Android Studio / Xcode configurados para emulador o dispositivo físico.

### Pasos
1. Abrir una terminal en el directorio del proyecto:
   ```bash
   cd c:\Users\Manue\Documents\Developer\sistema-asistencia-mobile
   ```

2. Obtener dependencias:
   ```bash
   flutter pub get
   ```

3. Ejecutar en emulador o dispositivo conectado:
   ```bash
   flutter run
   ```
