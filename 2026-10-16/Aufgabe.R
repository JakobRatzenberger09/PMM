1) 
dbinom(0:3, size = 20, prob = 0.05)
[1] 0.35848592 0.37735360 0.18867680 0.05958215

2) 
barplot(dbinom(0:20, size = 20, prob = 0.05), names.arg = 0:20)
Beschreibung der Form: Die Verteilung ist rechtsschief (bzw. stark asymmetrisch), da die Erfolgswahrscheinlichkeit $p = 0.05$ sehr klein ist und die Wahrscheinlichkeiten für größere Werte schnell gegen Null gehen.

3)
Antwort: Es gibt genau einen Weg, aus null Elementen null Elemente auszuwählen – nämlich die leere Menge (gar nichts auszuwählen). Kombinatorisch entspricht dies genau einer Möglichkeit.