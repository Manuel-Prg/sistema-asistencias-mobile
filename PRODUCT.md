# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

- **Alumnos de Servicio Social y Prácticas Profesionales:** Estudiantes universitarios activos que cumplen su compromiso institucional en las instalaciones físicas de la Casa Universitaria del Agua.
- **Voluntarios del Recinto:** Miembros de apoyo acreditados en actividades y talleres de conservación ambiental e hídrica.
- **Límite de Rol:** Exclusivo para estudiantes y voluntarios (`student`). Los supervisores y administradores operan de forma estricta y exclusiva desde la plataforma web existente. Si un supervisor intenta iniciar sesión en la app móvil, el sistema deniega el acceso y lo redirige a la web.

## Product Purpose

Proporcionar a los alumnos una herramienta móvil ágil, nativa y libre de fricciones para registrar su asistencia diaria en el recinto físico en menos de cinco segundos, eliminando la dependencia del navegador web móvil. Garantiza transparencia total sobre las horas acumuladas hacia su meta de acreditación, el cumplimiento de su horario pactado y el estatus disciplinario de tolerancias y retardos.

## Positioning

Frente a la versión web general pensada para supervisión de escritorio y pantallas amplias, la aplicación móvil es la herramienta de campo personal del alumno: opera directamente desde su bolsillo al llegar al recinto, ofrece marcaje inmediato de entrada/salida por sala asignada, cuenta regresiva en vivo de horas trabajadas y visualización clara del límite de tolerancia (15 minutos) con advertencias tempranas antes de incurrir en faltas.

## Operating Context

- **Ubicación:** Recinto físico de la Casa Universitaria del Agua (Salas 1 a 4, Galería, Site, etc.).
- **Jornadas y Turnos:** Turnos matutino (11:00 - 14:00) y vespertino (14:00 - 18:00) de martes a domingo (lunes cerrado).
- **Conectividad:** Dispositivos móviles personales de los estudiantes conectados a redes Wi-Fi institucionales o datos móviles locales.
- **Ritual Diario:** Apertura de la app al ingresar a la sala, selección de turno y sala asignada, check-in en un toque, visualización del temporizador durante la jornada y check-out al concluir.
- **Condiciones de Iluminación:** Uso en interiores de oficinas/aulas y áreas abiertas del recinto, requiriendo soporte nativo para Modo Claro (Canteras y Piedra Caliza) y Modo Oscuro (Azul Abisal).

## Capabilities and Constraints

- **Check-in y Check-out Ultrarrápidos:** Registro de entrada con validación de sala y turno; marcaje de salida con temporizador continuo.
- **Salidas Tempranas Auditadas:** Si la jornada es menor al turno mínimo reglamentario (3 horas), se exige declaración de motivo justificado (`Enfermedad`, `Imprevisto personal`, `Emergencia familiar`, `Otra razón`).
- **Tope de Horas Acreditables:** Jornadas regulares acreditadas hasta un máximo de 10.0 horas; jornadas en eventos especiales autorizados acreditan horas dobles (2x) hasta un máximo de 20.0 horas.
- **Reglas Disciplinarias de Asistencia:**
  - Tolerancia de 15 minutos respecto al horario configurado por el alumno en "Tu Horario".
  - Retardo automático al superar 15 minutos tras la hora pactada.
  - Regla de conversión 3:1: 3 retardos no justificados acumulan automáticamente 1 falta.
  - Alerta máxima institucional al alcanzar 3 faltas (riesgo inminente de baja del servicio).
- **Notificaciones y Alertas:** Avisos dentro de la app con el asistente Nuty/Skippy más notificaciones locales programadas para recordar el inicio de turno según el horario pactado.
- **Heatmap de 16 Semanas:** Cuadrícula de actividad histórica estilo contribución para inspeccionar cada jornada, retardos y horas acreditadas.
- **Directorio de Estudiantes Activos:** Hoja modal en vivo para consultar quiénes se encuentran en turno actualmente en el recinto.

## Brand Commitments

- **Identidad Institucional:** Casa Universitaria del Agua.
- **Paleta Cromática ("Canales de Cantera y Espejo de Agua"):**
  - Azul Estanque Primario (`#0C3C4C`)
  - Cantera y Sillar Cálido (`#F4F1EA`, `#FAF8F3`)
  - Acento Limnológico (`#087E8B`)
  - Terracota Reglamentaria (`#B84A27`, `#C26D2D`)
  - Señal de Agua / Aqua Vivo (`#5EEAD4`)
- **Tono y Voz:** Institucional, cálido, riguroso y transparente.
- **Asistente Satírico (Nuty / Skippy):** La nutria mascota de la Casa Universitaria acompaña los avisos disciplinarios y felicitaciones con citas deterministas y mordaces pero empáticas cuando hay riesgo de faltas o celebración al 100%.

## Evidence on Hand

- **Base de Datos de Producción:** Instancia Supabase en PostgreSQL (`https://xijynpbqfdavdueycric.supabase.co`) con tablas de autenticación, perfiles, registros de asistencia y horarios.
- **Identidad Gráfica:** Logotipos vectoriales y rasterizados en `assets/logo/` (`iconoFavicon.png`, `logo_remove_background.png`) e ilustraciones de la nutria Nuty en `assets/images/nuty/`.
- **Reglamento Operativo:** Criterios oficiales de tolerancia (15 min), turno mínimo (3 hrs), topes (10h/20h) y penalizaciones consolidadas en `lib/core/constants/app_constants.dart`.

## Product Principles

1. **Velocidad sin Obstáculos:** El check-in de entrada y salida debe poder completarse en menos de 5 segundos desde el momento en que se abre la app.
2. **Cero Ambigüedad Disciplinaria:** El estudiante siempre sabe con exactitud cuántos minutos de tolerancia tiene, cuántos retardos lleva y a qué distancia se encuentra de una falta o baja.
3. **Fidelidad al Recinto Físico:** Todo el flujo responde a la realidad de estar presente en la Casa Universitaria del Agua (salas, turnos matutino/vespertino, eventos especiales).
4. **Respeto a los Límites de Rol:** La app es el espacio del estudiante; jamás expone ni confunde herramientas de supervisión que pertenecen a la web.

## Accessibility & Inclusion

- Soporte nativo para escalas de fuente de accesibilidad del sistema operativo sin truncamiento ni desbordamiento de componentes.
- Contraste visual estricto en Modo Claro y Modo Oscuro conforme a WCAG AA para entornos con reflejo solar en exteriores o salas con iluminación tenue.
- Targets táctiles mínimos de 48x48 dp en todos los botones de interacción crítica (Check-in, Check-out, selector de salas y horarios).

