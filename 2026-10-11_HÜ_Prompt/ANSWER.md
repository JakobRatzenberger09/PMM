# Antwort — Welche Inhalte der 3. Klasse lassen sich mit R effizienter lösen?

Antwort auf den Prompt in [`PROMPT.md`](PROMPT.md). Bezug: 3. Jahrgang PMM,
**KM5** (Verteilungen & Schätzer) und **KM6** (Vertrauensbereiche, Prüfergebnisse,
Lebensdauer).

## 1. Übersicht

| Thema (KM) | Bisher (Taschenrechner/händisch) | Mit R (Funktion/Paket) | Warum effizienter |
|---|---|---|---|
| Binomialkoeffizient & Pascalsches Dreieck (KM5) | Fakultäten tippen, Dreieck aufzeichnen | `choose()`, `factorial()` | Kein Fakultäts-Chaos bei großen `n`, sofort exakt |
| Binomialverteilung (KM5) | Formel + Tabelle für P(X=k), P(X≤k) | `dbinom()`, `pbinom()`, `qbinom()` | Summen und Nachschlagen entfallen; Schwellen direkt berechenbar |
| Ziehen ohne Zurücklegen / hypergeometrisch (KM5) | Baumdiagramm, Kombinationen von Hand | `dhyper()`, `phyper()` | Mehrstufige Ziehungen in einer Zeile statt Baum |
| Normalverteilung & z-Transformation (KM5) | z-Wert rechnen, dann Tabelle ablesen | `pnorm()`, `qnorm()`, `dnorm()` | Tabelle wird überflüssig; jede μ/σ-Kombination direkt |
| Exponentialverteilung (KM5) | e-Funktion mit λ einsetzen | `dexp()`, `pexp()` | Schnell, exakt, auch für viele Werte gleichzeitig |
| Lage- & Streumaße (KM5) | Mittelwert/Median/Varianz je Wert von Hand | `mean()`, `median()`, `sd()`, `var()`, `IQR()`, `quantile()` | Ganze Datenreihe in einem Aufruf, keine Übertragungsfehler |
| Parameter vs. Schätzwerte, Gesetz großer Zahlen (KM5) | einzelne Beispiele von Hand | Simulation mit `rnorm()`, `replicate()` | Verteilungen/Streuung durch viele Zufallsstichproben sichtbar machen |
| Standardfehler & KI für μ (σ bekannt) (KM6) | SE=σ/√n und z=1,96 einsetzen | `qnorm()` + `sd()/sqrt(n)` | Beliebig viele Intervalle automatisch |
| KI für μ (σ unbekannt) / t-Verteilung (KM6) | t-Tabelle, df ablesen | `t.test()`, `qt()` | df-Freiheitsgrade und Quantile automatisch |
| KI für σ² / χ²-Verteilung (KM6) | χ²-Tabelle beidseitig ablesen | `qchisq()` | Kein beidseitiges Tabellensuchen |
| Prüfergebnisse darstellen (KM6) | Diagramm per Hand zeichnen | `ggplot2`, Quarto | Saubere, reproduzierbare Grafiken in Sekunden |
| Kennzahlen & Ausreißer (KM6) | 1,5·IQR-Regel per Hand prüfen | `IQR()`, `quantile()` | Regel auf ganze Datensätze anwendbar |
| Lebensdauer: R(t), MTBF, Weibull (KM6) | Integrale/Formeln von Hand | `pexp()`, `pweibull()`, `fitdistrplus` | Zuverlässigkeit und Ausfallraten ohne Integralrechnung |

## 2. Fünf R-Codebeispiele

### a) Binomialverteilung — Annahmeschwelle (KM5)

```r
# Prüflos: n = 20 Teile, erwartete Ausschussquote p = 0,05
n <- 20; p <- 0.05

dbinom(0:5, size = n, prob = p)      # P(X = k) für k = 0..5
pbinom(2, size = n, prob = p)        # P(X <= 2): Annahmewahrscheinlichkeit
qbinom(0.95, size = n, prob = p)     # kritische Zahl c zum 95 %-Quantil
```

### b) Ziehen ohne Zurücklegen — hypergeometrisch (KM5)

```r
# Los mit 50 Teilen, davon 40 gut; 10 werden zufällig geprüft
dhyper(10, m = 40, n = 10, k = 10)   # P(alle 10 gut)
phyper(8, m = 40, n = 10, k = 10)    # P(höchstens 8 gut) -> Annahme?
```

### c) Normalverteilung — Ausschuss und 3-Sigma (KM5)

```r
# Sollwert 10,00 mm, sigma = 0,05 mm, Toleranz ±0,15 mm
mu <- 10; sigma <- 0.05
pnorm(10.15, mu, sigma) - pnorm(9.85, mu, sigma)   # guter Anteil (~0,9973)
1 - (pnorm(10.15, mu, sigma) - pnorm(9.85, mu, sigma))  # Ausschussanteil
qnorm(0.99865, mu, sigma)                          # obere 3-Sigma-Grenze
```

### d) Konfidenzintervall für den Mittelwert (KM6)

```r
x <- c(9.98, 10.01, 10.03, 9.97, 10.02, 9.99,
       10.05, 10.00, 9.96, 10.04, 9.98, 10.01)

t.test(x, conf.level = 0.95)                 # automatisch: t-Verteilung, df = n-1

# Kontrolle von Hand (soll dasselbe Intervall liefern):
n  <- length(x)
se <- sd(x) / sqrt(n)
mean(x) + c(-1, 1) * qt(0.975, df = n - 1) * se
```

### e) EDA, Ausreißer und Lebensdauer (KM6)

```r
library(tidyverse)

# Ausreißer nach der 1,5·IQR-Regel
grenzen <- quantile(x, c(0.25, 0.75))
iqr     <- IQR(x)
tibble(masse_mm = x) |>
  filter(masse_mm < grenzen[1] - 1.5 * iqr | masse_mm > grenzen[2] + 1.5 * iqr)

# Prüfergebnisse darstellen
ggplot(tibble(masse_mm = x), aes(x = masse_mm)) +
  geom_histogram(binwidth = 0.02, fill = "grey70", color = "white") +
  labs(x = "Maß (mm)", y = "Anzahl")

# Weibull-Lebensdauer: Form beta = 1,5, Skala eta = 5000 h
pweibull(1000, shape = 1.5, scale = 5000)        # F(t): Ausfall bis 1000 h
1 - pweibull(1000, shape = 1.5, scale = 5000)    # R(t): Zuverlässigkeit
5000 * gamma(1 + 1 / 1.5)                        # MTBF (eta * Gamma(1 + 1/beta))
```

## 3. Fazit

R lohnt sich überall dort, wo **viele Werte, Verteilungen oder Wiederholungen**
im Spiel sind: Verteilungsfunktionen ersetzen das Tabellen-Nachschlagen,
Skripte machen die Rechnung reproduzierbar, und `ggplot2` liefert sofort
saubere Grafiken. **Von Hand** bleibt sinnvoll, was das Verständnis schult:
das Aufstellen der Formel, eine schnelle Überschlagsrechnung und das
Interpretieren des Ergebnisses – denn die Zahl allein ersetzt keine Deutung.
Kurz: **rechnen lässt man R, verstehen und bewerten muss man selbst.**
