# FitFlow — app Swift/SwiftUI de entrenamiento

Scaffold funcional en Swift/SwiftUI, pensado para abrirlo en Xcode y seguir
iterando con OpenCode. Incluye:

- **Auth con Supabase** (email/contraseña) — `Services/SupabaseService.swift`
- **Cronómetro genérico por intervalos** (`Timer/IntervalTimerEngine.swift`) que
  respeta segundos exactos de trabajo/descanso, avanza solo y pita en cada
  transición (pitidos generados por código con `AVAudioEngine`, sin mp3s).
- **Stickman animado 100% custom** con `Canvas` + `TimelineView` (nada de
  iframes ni vídeos incrustados) — 7 ejercicios de core ya definidos y
  fácilmente ampliables (`Stickman/StickmanPoseLibrary.swift`).
- **Parser de tu notación de carrera** (`Models/RunningNotationParser.swift`)
  que entiende cosas como `5´RM + 4 x (1´ RA + 1´30"´RS) + 8´ RM` y las
  convierte en fases cronometradas con colores por ritmo (RA/RM/RS).
- **Las 36 sesiones de carrera de tu Excel** (CARRERA 1/2/3, solo carrera,
  sin fuerza) ya cargadas como datos semilla en
  `Models/RunningWorkoutLibrary.swift`, listas para reproducir o editar.
- Un campo de **notación personalizada** en la pantalla de Carrera, con
  vista previa en vivo del parseo.

## 1. Crear el proyecto en Xcode

1. Xcode → File → New → Project → **iOS → App**. Nombre: `FitFlow`,
   interfaz **SwiftUI**, lenguaje **Swift**.
2. Borra el `ContentView.swift` y `FitFlowApp.swift` que genera Xcode por
   defecto.
3. Arrastra la carpeta `FitFlowApp/` (todo su contenido, manteniendo la
   estructura de grupos) dentro del proyecto en Xcode, marcando "Copy items
   if needed" y añadiéndolo al target de la app.
4. File → Add Package Dependencies → añade
   `https://github.com/supabase/supabase-swift` (versión reciente ≥ 2.x).
5. En `Services/SupabaseService.swift`, sustituye `YOUR-PROJECT` y
   `YOUR-ANON-KEY` por los de tu proyecto Supabase (Settings → API).
6. Ejecuta `supabase/schema.sql` en el SQL editor de tu proyecto Supabase.
7. Run ▶️ en el simulador.

La API exacta del SDK de Supabase (`auth.signUp`, `auth.authStateChanges`,
etc.) puede variar ligeramente según la versión que instales — si Xcode
marca algún error de compilación ahí, es lo primero que hay que ajustar
(está señalado con comentarios en el propio archivo).

## 2. Qué es real y qué es punto de partida

**Ya funciona tal cual:**
- El parser de notación de carrera y los datos de tus 36 días.
- El motor de cronómetro (segundos exactos, pitidos, auto-avance).
- El stickman animado (7 ejercicios de core, en bucle ida-vuelta).
- Las pantallas de selección y reproducción, para abdominales y carrera.

**Diseñado para que sigas iterando con OpenCode:**
- Solo hay 7 ejercicios de core con animación propia. Añadir uno nuevo es
  crear una `StickmanAnimation` más en `StickmanPoseLibrary.swift` (2-3
  keyframes de posiciones normalizadas 0...1) y una entrada en
  `AbExerciseLibrary`.
- El parser cubre bien el patrón de tu Excel, pero notaciones muy distintas
  pueden caer en un fallback "manual" (fase de nota, sin cronómetro) en vez
  de romperse — revísalo con casos raros propios.
- No hay persistencia de progreso todavía (las tablas de `schema.sql` están
  listas, falta conectarlas desde la app).
- No hay efectos de partícula / haptics de "power" todavía — hay hooks
  claros donde añadirlos (`RingProgressView`, el pulso alrededor del anillo).

## 3. Prompts sugeridos para continuar con OpenCode

Cópialos tal cual, uno por sesión de trabajo:

```
Añade persistencia real: al completar un circuito de abdominales o una
sesión de carrera, guarda un registro en Supabase usando las tablas de
supabase/schema.sql (ab_workout_logs / running_workout_logs). Muestra un
historial simple en una nueva pestaña "Progreso".
```

```
Añade haptics (UIImpactFeedbackGenerator) en cada transición de fase del
IntervalTimerEngine, y un efecto visual de "flash" de color de medio
segundo sobre RingProgressView cuando empieza cada fase nueva.
```

```
Amplía StickmanPoseLibrary con estos ejercicios nuevos: [lista de
ejercicios]. Sigue el mismo patrón de 2-3 keyframes normalizados que ya
usan plank/crunch/legRaise.
```

```
Convierte la Home en un TabView con pestañas Inicio / Fuerza / Carrera /
Progreso / Perfil, moviendo la navegación actual dentro de cada pestaña.
```
