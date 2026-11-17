* ============================================================
* A5 — Limpieza y descriptivos de CASEN
* Autor: Francisco Inostroza      Fecha: 17-11-2026
* ============================================================
clear all
set more off
capture mkdir "output"
capture log close
log using "output/tarea_a5.log", replace text

* 1. Carga los datos
import delimited "data/raw/casen_reducido.csv", clear varnames(1) encoding("utf-8")
describe
summarize

* 2. Crea variables con generate y replace
* Experiencia potencial de Mincer
generate experiencia = max(edad - educ - 6, 0)

* Variable indicadora (dummy) y un uso de replace sobre una variable ya creada
generate alta_educ = 0 if !missing(educ)
replace  alta_educ = 1 if educ >= 13 & !missing(educ)

* Variable categórica numérica desde texto 
encode sector, generate(sector_n)

* 3. Etiqueta variables y valores
label variable experiencia "Experiencia potencial (años)"
label variable alta_educ   "Educación superior (13+ años)"

label define lbl_educ 0 "Menos de 13 años" 1 "13+ años"
label values alta_educ lbl_educ

* 4. Cuidado con los missing
count if missing(ingreso)

* Comprobación del gotcha de los missing:
count if ingreso > 500000
count if ingreso > 500000 & !missing(ingreso)

* Comentario sobre los missing:
* `summarize ingreso` no se equivoca con los missing porque por defecto los excluye
* y calcula todo solo sobre las 55 observaciones con dato válido. En cambio, al filtrar
* con `count if ingreso > 500000` sin excluirlos, Stata trata al missing (.) como un
* número mayor que cualquier cifra real y cuenta erróneamente como ingresos altos a
* las 5 personas que no tienen dato (dando 46 en vez de 41).

* 5. Descriptivos
summarize ingreso educ edad experiencia

* Guardo la media de ingreso con scalar antes de que el siguiente comando borre r()
scalar media_ingreso = r(mean)
display "Ingreso medio muestral: $" media_ingreso

tabulate sector
tabulate genero alta_educ, row
summarize ingreso if alta_educ == 1
summarize ingreso if alta_educ == 0
correlate ingreso educ experiencia

* 6. Cierre de la bitácora 
log close

* Interpretación:
* En la muestra de 60 personas (55 con dato de ingreso), el ingreso mensual promedio
* es de $655.291 y la escolaridad media alcanza los 12,7 años. Al separar por nivel
* educativo, quienes tienen 13 o más años de estudio presentan un ingreso promedio de
* $777.926, frente a los $537.036 de quienes tienen menos de 13 años. Además, los años
* de educación se asocian positivamente con el ingreso (r = 0,68), mientras que la
* experiencia potencial muestra una asociación lineal casi nula (r = -0,09).
