rebol [Title: "REGISTRO DE COBRANZA MONKYS V2.01"
		Author: Valentin Coellar Serrano
		Date: 14/9/2011		
		Bussines: "Grupo Moscaro"
]

do %rebgui.r
do %list-view.r


;secure  [file allow]
; --- TO-DO

;  >> 14/09/2011 se ajustaron sizes de celdas
;  >> 14/09/2011 panel de botones AGREGAR,GUARDAR ,REPORTE ,ACTUALIZAR WEB
;  >> 14/09/2011 introduccion de datos en tabla FUNCION AGREGAR y panel 
;  >> 14/09/2011 formulas en tabla ,para calculo de dias pendientes y creditos
;  >> 18/09/2011 funcion de reporte
;  >> 14/09/2011 calcular dias de credito
;  >> 14/09/2011 panel para agregar
;  >> 14/09/2011 funcion para agregar columnas en tabla
;  >> 14/09/2011 funcion guardar en disco
;  >> 18/09/2011 cuerpo de reporte
;  >> 18/09/2011 encabezado de reporte
;  >> 18/09/2011 sorting de reporte segun fecha de vencimiento
;  >> 21/09/2011 reporte coloreando rojas y amarillas segun rango al dia de hoy
;  >> 28/09/2011 eliminacion de items sobre tabla
;  >> 22/02/2012 tamaño de letra y fuente en reporte html ampliado
;  >> habilitar modo de edicion para cada ITEM
;  >> 22/02/2012 funcion actualizacion web envio de correos electronicos
; >> colocar monedas correctamente
; >> reporte totales 
;  >> 05/03/2012 panel de edicion para items
;  >> 08/04/2012 creacion de funcion BROKER 
; >>
; >>
; >>
; >>

; ---  Relacion de Campos -----------
; factura		/FAC_SET
; cliente		/CLIE_SET
; fecha de aplicacion	/FEC_APLIC_SET
; dias credito		/DIAS_CRED_SET
; fecha de vencimiento	/FEC_VENC_SET
; importe		/IMPORTE_SET
; iva			/IVA_SET
; total			/TOTAL_SET
; factura original	/FAC_ORIG_SET
; a/c			/A_CUENTA_SET
; saldo pendiente 	/S_PENDIENTE_SET
; No. Cheque		/NO_CHEQUE_SET
; banco			/BANCO_SET
; transferencia		/TRANSFERENCIA_SET
; cheque posfechado	/C_POSFECHADO_SET


rango_red: 4
rango_yellow: 5
rango_green: 10

; ------- FIN RELACION DE CAMPOS ------

; ////////// ENCABEZADO PARA CORREO ELECTRONICO ///////

system/user/email: direccion@gruponucleon.com
system/user/name: "SISTEMA DE COBRANZA"
system/schemes/esmtp/host: "mail.gruponucleon.com"
system/schemes/esmtp/port-id: 587
system/schemes/esmtp/user: "direccion@gruponucleon.com"
system/schemes/esmtp/pass: "Millonario1"



; --------------------- MODULO BROKER --------------------------------
; 1- verificar si estamos en internet colocar flag 			Net_Ready = true/false
; 2- verificar igualdad de COBRANZA.txt y CONTROL.TXT flag 	iguales = true/false
; 3- 
BROKER: does [
Net_Ready: connected?   


a: read http://www.gruponucleon.com/control.txt
b: read %cobranza.txt

iguales:  equal? a b   

valores_control: read %control.txt
valores_data: read %cobranza.txt

site_file_control: ftp://u144733:Millonario1@www.gruponucleon.com//public_html/control.txt
site_file_data: ftp://u144733:Millonario1@www.gruponucleon.com//public_html/cobranza.txt
site_files_data_local: read %cobranza.txt
; /*/*/*/*/*/*/ end variables /*/*/*/*/*/*/*/*/



write site_file_control valores_control
write site_file_data valores_data

request/ok  "Informacion Sincronizada con Exito"





]
; --------------------- END MODULO BROKER ----------------------------





AGREGAR_FACTURA: does [
display "Agregar Factura" [
text "Factura" campo1: field 14x5
text "Cliente" campo2: field
return
text "Fecha aplicacion DD/MM/AAAA" campo3: field 20x5 
text "Dias de Credito" campo4: field 7x5
return
text "Importe" campo5: field 20x5
text "Factura original" campo6: field 14x5
text "A cuenta: " campo7: field 20x5
return
text "No. de Cheque" campo8: field 14x5
text "Comentarios" campo9: field
return
text "Transferencia" campo10: check 
text "Cheque Posfechado" campo11: check



button "ok" [
; --- formulas y conversiones ----

fecha_v: (to-date campo3/text) + (to-integer campo4/text)
iva:(to-decimal campo5/text) * 0.16
iva_total: (to-decimal campo5/text) * 0.16 + (to-decimal campo5/text)
saldo: iva_total - (to-decimal campo7/text)
if campo10/data = none [campo10/data: "NO"]
if campo10/data = true [campo10/data: "SI"]
if campo11/data = none [campo11/data: "NO"]
if campo11/data = true [campo11/data: "SI"]

;informacion: to-block join tabla/data campo2/text
informacion: to-block rejoin[ mold campo1/text mold campo2/text mold to-date  campo3/text mold campo4/text mold to-string fecha_v to-money campo5/text mold to-string (to-money iva)  mold to-string (to-money iva_total) mold to-string campo6/text mold (to-money campo7/text) mold to-string (to-money saldo) mold to-string campo8/text mold to-string campo9/text mold to-string campo10/data  mold to-string campo11/data]


insert head tabla/data informacion
;tabla/add-row informacion
tabla/redraw

] 

]]



REPORTE_GENERAL: does [
; /////// REPORTE EN HTML LISTO PARA PUBLICAR ////

nibble_a: 1 
nibble_b: 15
datos: tabla/data
largo: length? tabla/data
items: tabla/rows
indice_maestro: 0
indice_lectura: 0
flag: "bgcolor='white'"
IMPORTE2: 0
IVA_TOTAL2: 0
TOTAL2: 0
ACUENTA2: 0
SALDOP2: 0
;---------------------------- START REPORT --------------------- 

write %reporte_cobranza.html rejoin [[<html><body> <IMG SRC="logo.jpg" width=90 height=50> <br> "Corte Realizado el :  " ] now/date " <br> Relacion de Cobranza"] 



write/append %reporte_cobranza.html [</tr></h4></table><hr></HTML>]
write/append %reporte_cobranza.html [<table border=1 cellspacing=0 cellpadding="4" >]
write/append %reporte_cobranza.html [<th><font size="1">FACTURA </th> <th><font size="1">CLIENTE</th> <th><font size="1">FECHA_APLICACION</th><th><font size="1"> DIAS_DE_CREDITO </th><h4><th><font size="1"> FECHA_VENCIMIENTO </th> <h4><th><font size="1"> IMPORTE </th> <h4> <h4><th><font size="1"> IVA </th>
<h4><th><font size="1"> TOTAL </th><h4><th><font size="1"></th><h4><th><font size="1">A_CUENTA </th><h4><th><font size="1">SALDO_PENDIENTE </th>
<h4><th><font size="1"></th><h4><th><font size="1">.............................................COMENTARIOS.............................................</th><h4><th><font size="1">TRANSFERENCIA</th><h4><th><font size="1">CHEQUE_POSFECHADO</th>]

write/append %reporte_cobranza.html rejoin [[<tr>]]



repeat count items [tabla/select-row count indice_lectura: tabla/selected 
;print to-date indice_lectura/5 
;print "rango"
;print (now/date + rango_yellow )    ; control de desiciones

; -*-*-*-*- RANGOS *-*-*-*-*-*-
IMPORTE: indice_lectura/6            
IMPORTE2: IMPORTE + IMPORTE2
IVA_TOTAL: TO-MONEY indice_lectura/7
IVA_TOTAL2: IVA_TOTAL + IVA_TOTAL2
TOTAL: TO-MONEY indice_lectura/8
TOTAL2: TOTAL + TOTAL2
ACUENTA: TO-MONEY indice_lectura/10
ACUENTA2: ACUENTA + ACUENTA2
SALDOP: TO-MONEY indice_lectura/11
SALDOP2: SALDOP + SALDOP2


;PRINT IMPORTE2 ;SUMATIVA DE LOS IMPORTES


;0-0-0--0-0-0-0-0-0 contador de totales -0-0-00--0-0-0-0-0-0-0-0


;if any [(to-date indice_lectura/5) < (now/date - rango_red) (to-date indice_lectura/5) = (now/date - rango_red)] ;[flag: "bgcolor='red'"]





if (to-date indice_lectura/5) <= (now/date + rango_red) [flag: "bgcolor='silver'"]
if (to-date indice_lectura/5) > (now/date + rango_yellow) [flag: "bgcolor='yellow'"]
if (to-date indice_lectura/5) = (now/date + rango_yellow) [flag: "bgcolor='yellow'"]	
	;if (to-date indice_lectura/5) < (now/date - rango_red)  [flag: "bgcolor='silver'"]
	;if (to-date indice_lectura/5) < (now/date - rango_yellow) [flag: "bgcolor='yellow'"]
	;if (to-date indice_lectura/5) < (now/date - rango_green) [flag: "bgcolor='green'"]

; -*-*-*-*- END RANGOS *-*-*-*-*-*-

for countb nibble_a nibble_b 1 [indice_maestro: indice_maestro + 1 


write/append %reporte_cobranza.html rejoin ["<td " flag "><font size="3" face=tahoma >" tabla/data/:countb "</td>" ]]
		write/append %reporte_cobranza.html [<tr>]	
		nibble_a: nibble_a + 15
		nibble_b: nibble_b + 15
		flag: "bgcolor='white'"


;PRINT indice_lectura/7
]		
write/append %reporte_cobranza.html rejoin ["<td " flag "><font size="1">" " " "</td>" "<td " flag "><font size="1">" " " "</td>" "<td " flag "><font size="1">" " " "</td>" "<td " flag "><font size="1">" " " "</td>" "<td " flag "><font size="2">" "TOTAL: " "</td>" "<td " flag "><font size="2">" IMPORTE2 "</td>" "<td " flag "><font size="2">" IVA_TOTAL2 "</td>" "<td " flag "><font size="2">" TOTAL2 "</td>" "<td " flag "><font size="1">" " " "</td>" "<td " flag "><font size="2">" ACUENTA2 "</td>" "<td " flag "><font size="2">" SALDOP2 "</td>"]




; si a + 5 es > a hoy por rango entonces colorear de tal color


browse %reporte_cobranza.html
; -- end report --



] ; ////////// END REPORTE_GENERAL ////////////////
EDITAR: func [indice_row][
indice_edit: tabla/selected
if indice_edit <> none [
display "Editar Registro" [
text "Factura" campo1_editar: field 14x5 indice_edit/1
text "Cliente" campo2_editar: field	  indice_edit/2
return
text "Fecha aplicacion DD/MM/AAAA" campo3_editar: field 20x5  (to-string indice_edit/3)
text "Dias de Credito" campo4_editar: field 7x5		 indice_edit/4         
return
text "Importe" campo5_editar: field 20x5 	         (to-string indice_edit/6)
text "Factura original" campo6_editar: field 14x5    indice_edit/9
text "A cuenta: " campo7_editar: field 20x5          (to-string indice_edit/10)
return
text "No. de Cheque" campo8_editar: field 14x5      indice_edit/12
text "Comentarios" campo9_editar: field					indice_edit/13
return
;text "Transferencia" campo10_editar: check 		indice_edit/14
;text "Cheque Posfechado" campo11_editar: check

button "ok" [

; al click el registro seleccionado toma los datos de los Campos
; print "Registro cambiado.."

;informacion_edit: to-block rejoin [mold campo1_editar/text					; factura
;								   mold campo2_editar/text					; cliente
; 								   mold to-date campo3_editar/text			; fecha_aplicacion
;  								   mold campo4_editar/text					; dias 
;  								   mold  indice_edit/5 				        ; FECHA_VENCIMIENTO
;  								   mold to-money campo5_editar/text			; importe $$
;  								   mold indice_edit/7 						; iva $$
;  								   mold to-money indice_edit/8    			; total $$
;  								   mold campo6_editar/text					; FACTURA ORIGINAL
;  								   mold campo7_editar/text			; A CUENTA $$
;  								   mold campo8_editar/text			        ; SALDO PENDIENTE $$
;  								   mold campo8_editar/text					; cheque
;  								   mold campo9_editar/text 					; BANCO // COMENTARIOS
;  								   mold indice_edit/14 						; transfer
;  								   mold indice_edit/15 						; cheque;
;
; 								  ] 

informacion_edit: to-block rejoin [
mold indice_edit/1 
mold indice_edit/2 
mold indice_edit/3 
mold indice_edit/4 
mold indice_edit/5 
mold indice_edit/6 
mold indice_edit/7 
mold indice_edit/8 
mold indice_edit/9 
mold indice_edit/10 
mold indice_edit/11 
mold indice_edit/12 
mold campo9_editar/text
mold indice_edit/14 
mold indice_edit/15 
									

]


; >>>>> REEMPLAZA EL REGISTRO CORRESPONDIENTE AL INDICE_ROW <<<<<<

tabla/ALTER-ROW indice_row informacion_edit

] ; salida de button
] ; salida de display 
tabla/redraw
] ; salida de if
] ; salida de funcion EDITAR 



ELIMINAR: does [  

kill_cursor: tabla/selected
kill_row: tabla/picked  ; el indice para eliminacion debe de ser numerico

;print kill_cursor
;print kill_row

if KILL_CURSOR <> none [
TO_KILL: request rejoin ["Eliminar este producto ? factura " kill_cursor/1 "   " kill_cursor/2] /ok if TO_KILL = true [tabla/remove-row kill_row]

tabla/redraw
]

]




; datos: load %cobranza.txt
;request-download http://www.servicorp2001.com/cobranza.txt
datos: load http://www.gruponucleon.com/cobranza.txt


main: DISPLAY "Registro de Cobranza MONKYS v2.01" [
TABLE-SIZE: 250X50


tabla: table  [on] options["Factura" left 0.06  
		"Cliente" left .1
		"Fecha_Aplicacion" left 0.08
		"Dias_Credito" left 0.04
		"Fecha_Ven" left 0.08
		"Importe" left 0.06
		"IVA"left 0.06
		"Total" left 0.06
		"Fact_Original" left 0.06
		"A_cuenta" left 0.06
		"Saldo_Pendiente" left 0.06
		"Cheque_No" left 0.06
		"Comentarios" left 0.06
		"Transferencia" left 0.06
		"Cheque_Posfechado" left 0.06

] data datos on-dbl-click [EDITAR tabla/picked]  
RETURN
button 30X10 "AGREGAR" [AGREGAR_FACTURA ] ;print tabla/picked print tabla/selected
button 30X10 "GUARDAR" [save %COBRANZA.txt tabla/data    save %CONTROL.txt tabla/data 
send/attach valcoellar@gmail.com "Base de datos Cobranza MOSCARO" [%COBRANZA.txt]
BROKER 
]
button 30X10 "REPORTE" [REPORTE_GENERAL]
button 30X10 "ENVIAR MAIL" [send/attach valcoellar@gmail.com "Reporte Cobranza Moscaro" [%reporte_cobranza.html] send/attach asistente@grupomoscaro.com "Reporte Cobranza" [%reporte_cobranza.html] send/attach direccion@grupomoscaro.com "Reporte Cobranza" [%reporte_cobranza.html] request/ok  "correo enviado a direccion@grupomoscaro.com  asistente@grupomoscaro.com"  ]  
;button 30x10 "EDITAR" [EDITAR tabla/picked print tabla/action]
text "Grupo Moscaro 2012" 
button 30X10 "ELIMINAR" [ELIMINAR]



] 
;tabla/action/on-dbl-click: [print "click clock"]
;on-dbl-click: [print "click clock"]


do-events






