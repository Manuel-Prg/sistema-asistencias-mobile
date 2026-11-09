---
name: Sistema de Asistencia - Casa Universitaria del Agua
description: Lenguaje visual institucional "Canales de Cantera y Espejo de Agua" para el control móvil de asistencia
colors:
  primary: "#0C3C4C"
  primary-deep: "#082935"
  secondary: "#EAE5DA"
  accent-limnological: "#0F766E"
  signal-aqua: "#5EEAD4"
  terracotta-rule: "#B84A27"
  amber-tolerance: "#C26D2D"
  limestone-ground: "#F4F1EA"
  sillar-card: "#FAF8F3"
  stone-border: "#D5CFC2"
  mineral-ink: "#12232B"
  slate-muted: "#465A63"
  abyssal-ground-dark: "#08171E"
  pond-card-dark: "#0D222C"
  dark-border: "#1E3A47"
  dark-text-primary: "#F4F1EA"
  dark-text-secondary: "#8BA2AD"
  status-on-time: "#10B981"
  status-late: "#991B1B"
  status-falta: "#EF4444"
  status-justified: "#0EA5E9"
  status-inactive: "#D1D5DB"
  status-inactive-dark: "#263942"
typography:
  display:
    fontFamily: "PT Serif, Georgia, serif"
    fontSize: "1.25rem"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "-0.01em"
  title:
    fontFamily: "Inter, sans-serif"
    fontSize: "1.125rem"
    fontWeight: 800
    lineHeight: 1.3
    letterSpacing: "0em"
  body:
    fontFamily: "Inter, sans-serif"
    fontSize: "0.875rem"
    fontWeight: 400
    lineHeight: 1.4
    letterSpacing: "0em"
  label:
    fontFamily: "Inter, sans-serif"
    fontSize: "0.9375rem"
    fontWeight: 700
    lineHeight: 1
    letterSpacing: "0.02em"
rounded:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  full: "9999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "12px"
  lg: "16px"
  xl: "20px"
  xxl: "24px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.limestone-ground}"
    rounded: "{rounded.md}"
    height: "50px"
  button-primary-dark:
    backgroundColor: "{colors.signal-aqua}"
    textColor: "{colors.abyssal-ground-dark}"
    rounded: "{rounded.md}"
    height: "50px"
  card-light:
    backgroundColor: "{colors.sillar-card}"
    rounded: "{rounded.lg}"
  card-dark:
    backgroundColor: "{colors.pond-card-dark}"
    rounded: "{rounded.lg}"
  glass-surface:
    backgroundColor: "{colors.sillar-card}"
    rounded: "{rounded.lg}"
  glass-navigation:
    backgroundColor: "{colors.sillar-card}"
    rounded: "{rounded.full}"
    height: "64px"
---

# Design System: Canales de Cantera y Espejo de Agua

## Overview

El sistema visual de la aplicación móvil de la Casa Universitaria del Agua se inspira en la arquitectura patrimonial hidráulica: la solidez mineral de la cantera y el sillar, contrastada con la serenidad del agua profunda de estanque y la señal luminiscente de canales y manantiales.

El diseño está concebido para operar bajo dos principios innegociables:
1. **Claridad operativa táctica:** El estudiante debe registrar su llegada o salida en segundos, con visibilidad indiscutible sobre sus horas acumuladas y estatus de tolerancia.
2. **Identidad matérica sobria:** Evita el aspecto genérico de plantillas SaaS. Se basa en cortes limpios de 1px, superficies mates de caliza y una placa activa en azul estanque profundo (`#0C3C4C`) que funciona como punto focal del recinto.

---

## Colors

### Colores Institucionales Principales
- **Azul Estanque Profundo (`primary`, `#0C3C4C`):** Base arquitectónica de la identidad, reservada para la barra superior, la tarjeta activa de check-in/out y acciones directas.
- **Azul Abisal (`primary-deep`, `#082935`):** Fondo para menús desplegables y contrastes de profundidad en superficies oscuras.
- **Señal Aqua (`signal-aqua`, `#5EEAD4`):** Acento vivo que denota estado activo, pulsos de sesión en curso y puntos focales en Modo Oscuro.

### Superficies y Neutros (Modo Claro)
- **Fondo Cantera (`limestone-ground`, `#F4F1EA`):** Fondo general de las pantallas diurnas.
- **Sillar Cálido (`sillar-card`, `#FAF8F3`):** Superficie para tarjetas informativas, listados y paneles.
- **Borde de Cantera (`stone-border`, `#D5CFC2`):** Delimitación nítida de 1px en tarjetas y separadores.
- **Tinta Mineral (`mineral-ink`, `#12232B`):** Tipografía principal con alto contraste y lectura natural.
- **Pizarra Apagada (`slate-muted`, `#465A63`):** Subtítulos, etiquetas secundarias e indicadores auxiliares.

### Superficies y Neutros (Modo Oscuro)
- **Fondo Abisal (`abyssal-ground-dark`, `#08171E`):** Fondo de bajo consumo lumínico para ambientes cerrados.
- **Tarjeta Estanque (`pond-card-dark`, `#0D222C`):** Superficie de tarjetas oscuras con bordes de 1px en `#1E3A47`.
- **Texto Principal Oscuro (`dark-text-primary`, `#F4F1EA`):** Texto cálido y descansado para la vista.

### Estados Disciplinarios y Heatmap
- **Puntual (`status-on-time`, `#10B981`):** Asistencia acreditada dentro de los 15 minutos de tolerancia.
- **Retardo (`status-late`, `#991B1B`):** Ingreso con más de 15 minutos de retraso.
- **Falta / Límite de Baja (`status-falta`, `#EF4444` / `terracotta-rule`, `#B84A27`): Alertas de penalización máxima.
- **Justificado (`status-justified`, `#0EA5E9`):** Incidencias validadas y salidas tempranas justificadas.
- **Acento Limnológico (`accent-limnological`, `#0F766E`):** Insignias de horas dobles (2x) en eventos y programas de servicio social.

---

## Typography

### Jerarquía Tipográfica
- **Display / Títulos Institucionales (AppBars):** `PT Serif`, 20sp, Bold (700), espaciado `-0.2sp`. Aporta peso institucional y formalidad patrimonial.
- **Títulos de Pantalla y Tarjetas:** `Inter`, 16sp – 18sp, Extra Bold (800) o Bold (700).
- **Métricas Numéricas (Horas y Porcentajes):** `Inter`, 28sp – 32sp, Extra Bold (800) con espaciado ajustado (`-1sp`).
- **Cuerpo de Texto y Formularios:** `Inter`, 13sp – 14sp, Regular (400) y Medium (500), altura de línea `1.4`.
- **Botones y Acciones (`labelLarge`):** `Inter`, 15sp, Bold (700), espaciado `0.3sp`.
- **Micro-etiquetas y Badges:** `Inter`, 10sp – 12sp, SemiBold (600) / Bold (700).

---

## Layout

- **Márgenes de Pantalla:** Padding simétrico de `16px` en todas las pantallas principales (`ListView` y `SingleChildScrollView`).
- **Estructura Modular:** Espaciado vertical rítmico de `12px` a `16px` entre tarjetas; separación de `24px` entre bloques temáticos.
- **Adaptabilidad y Flexibilidad:**
  - Todo elemento de fila (`Row`) con contenido textual dinámico o configurable debe protegerse con `Expanded` o `Flexible` y `TextOverflow.ellipsis`.
  - Los cronómetros en vivo emplean `FittedBox(fit: BoxFit.scaleDown)` para garantizar lectura íntegra en pantallas estrechas (320dp - 360dp) y con tamaños de fuente aumentados por accesibilidad.

---

## Elevation & Depth

- **Filosofía Tonal sobre Sombras:** La jerarquía se expresa predominantemente mediante contraste de color de superficie y bordes de piedra de 1px (`stone-border`), evitando sombras difusas excesivas.
- **Punto Focal Único (Tarjeta de Check-in):** Es el único elemento que proyecta una sombra suave (`BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: Offset(0, 6))`) sobre la superficie de fondo para indicar interactividad prioritaria.
- **Modales Inferiores (`BottomSheet`):** Esquinas superiores redondeadas a `24px`, fondo sólido y línea de arrastre sutil de 4px de grosor.

---

## Shapes

- **Tarjetas Principales:** Radio de curvatura de `16px` (`rounded.lg`), con borde perimetral de 1px.
- **Tarjeta Focal de Marcaje:** Radio de `20px` (`rounded.xl`).
- **Botones Principales y Entradas de Texto:** Radio de `12px` (`rounded.md`).
- **Píldoras de Estado y Turnos (`Chips`):** Radio completo de `20px` a `9999px` (`rounded.full`).
- **Celdas de Heatmap (Actividad de 16 semanas):** Módulos cuadrados de `14x14 px` con radio de `2.5px`.

---

## Components

### 1. Botón Primario (`ElevatedButton`)
- **Modo Claro:** Fondo `#0C3C4C`, texto `#F4F1EA`, altura mínima de `50px`.
- **Modo Oscuro:** Fondo `#5EEAD4`, texto `#08171E`, altura mínima de `50px`.
- **Estado de Carga:** Spinner circular blanco o contrastante de 22x22 px con trazo de `2.5px`.

### 2. Botón Secundario (`OutlinedButton`)
- Borde de `1.5px` en el color primario correspondiente (`#0C3C4C` en claro, `#5EEAD4` en oscuro, `#B84A27` para cerrar sesión).
- Sin elevación, manteniendo la misma altura mínima de 50px para consistencia táctil.

### 3. Tarjeta de Asistencia Diaria (`CheckInOutCard`)
- Placa destacada que conmuta limpiamente entre **Modo Entrada** (selector de sala y turno matutino/vespertino) y **Modo Salida** (cronómetro tabular en tiempo real y alerta de salida temprana si es menor a 3 horas).

### 4. Cuadrícula de Heatmap de 16 Semanas (`AttendanceHeatmapCard`)
- Visualización histórica estilo GitHub en desplazamiento horizontal reverso (semana más reciente a la derecha).
- Indicador visual de tolerancia con contador segmentado de 9 casillas para retardos (donde cada 3 retardos se transforman en 1 falta) y barra de riesgo de baja institucional.

---

## Do's and Don'ts

### Do's
- Mantener siempre targets táctiles mínimos de `48x48 dp` en todos los controles interactivos.
- Utilizar `FittedBox` y `TextOverflow.ellipsis` en filas donde convivan textos dinámicos con iconos o contadores.
- Validar siempre los dos temas (Modo Claro y Modo Oscuro) asegurando contraste WCAG AA en textos sobre fondo.
- Dejar las citas mordaces de Skippy/Nuty exclusivamente para advertencias disciplinarias reales (retardos acumulados / riesgo de baja) y felicitaciones del 100% de horas.

### Don'ts
- **No introducir componentes de supervisión:** La app móvil es 100% para estudiantes; nunca incluir botones de edición masiva, descarga de nóminas o reportes globales de recinto que pertenecen a la web.
- **No usar sombras arbitrarias o difuminados pesados:** La estética es mineral, limpia y nítida.
- **No hardcodear tamaños de texto en px rígidos:** Utilizar siempre las escalas tipográficas del tema que respetan las opciones de accesibilidad del sistema operativo.
- **No permitir que el registro de check-in quede bloqueado sin conexión:** Presentar siempre mensajes descriptivos y reintentos claros si falla la red con Supabase.
