rebol [
	Title: "System Proto V2.0"
	Author: Valentin Coellar S.
]

do %list-view.r

;  >>>> TO-DO 
; ----- lista 2 
; ----- numero de ticket para cada orden
; ----- nombre de usuario y password
; corte x
; corte y
; reporte general
; reporte en HTML

;//// botones ////  serie [nombre DescripcionTicket precio]
;RED
red_boton1: ["producto1" "descripcion1" 10]
red_boton2: ["producto2" "descripcion2" 20]
red_boton3: ["producto3" "descripcion3" 30]
red_boton4: ["producto4" "descripcion4" 40]
red_boton5: ["producto5" "descripcion5" 50]
red_boton6: ["producto6" "descripcion6" 60]
red_boton7: ["producto7" "descripcion7" 70]
red_boton8: ["producto8" "descripcion8" 80]
red_boton9: ["producto9" "descripcion9" 90]
red_boton10: ["producto10" "descripcion10" 100]
;GREEN
green_boton1: ["producto1" "descripcion1" 10]
green_boton2: ["producto2" "descripcion2" 20]
green_boton3: ["producto3" "descripcion3" 30]
green_boton4: ["producto4" "descripcion4" 40]
green_boton5: ["producto5" "descripcion5" 50]
green_boton6: ["producto6" "descripcion6" 60]
green_boton7: ["producto7" "descripcion7" 70]
green_boton8: ["producto8" "descripcion8" 80]
green_boton9: ["producto9" "descripcion9" 90]
green_boton10:["producto10" "descripcion10" 100]
;YELLOW
yellow_boton1: ["producto1" "descripcion1" 10]
yellow_boton2: ["producto2" "descripcion2" 20]
yellow_boton3: ["producto3" "descripcion3" 30]
yellow_boton4: ["producto4" "descripcion4" 40]
yellow_boton5: ["producto5" "descripcion5" 50]
yellow_boton6: ["producto6" "descripcion6" 60]
yellow_boton7: ["producto7" "descripcion7" 70]
yellow_boton8: ["producto8" "descripcion8" 80]
yellow_boton9: ["producto9" "descripcion9" 90]
yellow_boton10:["producto10" "descripcion10" 100]
;BLUE
blue_boton1: ["producto1" "descripcion1" 10]
blue_boton2: ["producto2" "descripcion2" 20]
blue_boton3: ["producto3" "descripcion3" 30]
blue_boton4: ["producto4" "descripcion4" 40]
blue_boton5: ["producto5" "descripcion5" 50]
blue_boton6: ["producto6" "descripcion6" 60]
blue_boton7: ["producto7" "descripcion7" 70]
blue_boton8: ["producto8" "descripcion8" 80]
blue_boton9: ["producto9" "descripcion9" 90]
blue_boton10:["producto10" "descripcion10" 100]

; --------------------- FUNCTION  BOX ---------------

TO_PAY: does [suma: $0 index: 0 foreach item ticket/data [index: index + 1  suma: suma + to-money ticket/data/(index)/3  ]	pago_total/text: to-string  suma show pago_total ]

ORDER_ADD_ITEM: does [total: to-money (precio * cant)  ticket/append-row/values rejoin [ product cant total ]  TO_PAY   ] 

MODIFY_ITEMS: does [bloke: ticket/get-row 	modify:	request rejoin [ "Eliminar esta Producto ? " (to-string bloke/1)] /ok if modify = true [ticket/remove-row ] TO_PAY ]


; ---------------------------------------------------


view layout [size 800x650  backdrop effect [gradient 0x1 orange] 


; --- inicia buttons panel --------------------------

;/// RED

button red red_boton1/1	 [precio: red_boton1/3 cant: 1 product: to-block mold red_boton1/2 ORDER_ADD_ITEM
cant: 0]  
button red red_boton2/1	 [precio: red_boton2/3 cant: 1 product: to-block mold red_boton2/2 ORDER_ADD_ITEM
cant: 0]
button red red_boton3/1	 [precio: red_boton3/3 cant: 1 product: to-block mold red_boton3/2 ORDER_ADD_ITEM
cant: 0]
button red red_boton4/1	 [precio: red_boton4/3 cant: 1 product: to-block mold red_boton4/2 ORDER_ADD_ITEM
cant: 0]
button red red_boton5/1	 [precio: red_boton5/3 cant: 1 product: to-block mold red_boton5/2 ORDER_ADD_ITEM
cant: 0]
button red red_boton6/1	 [precio: red_boton6/3 cant: 1 product: to-block mold red_boton6/2 ORDER_ADD_ITEM
cant: 0]
button red red_boton7/1	 [precio: red_boton7/3 cant: 1 product: to-block mold red_boton7/2 ORDER_ADD_ITEM
cant: 0]
button red red_boton8/1	 [precio: red_boton8/3 cant: 1 product: to-block mold red_boton8/2 ORDER_ADD_ITEM
cant: 0]
button red red_boton9/1	 [precio: red_boton9/3 cant: 1 product: to-block mold red_boton9/2 ORDER_ADD_ITEM
cant: 0]
button red red_boton10/1	 [precio: red_boton10/3 cant: 1 product: to-block mold red_boton10/2 ORDER_ADD_ITEM
cant: 0]
return
;/// GREEN

button 0.105.90 green_boton1/1	 [precio: green_boton1/3 cant: 1 product: to-block mold green_boton1/2 ORDER_ADD_ITEM
cant: 0]  
button 0.105.90 green_boton2/1	 [precio: green_boton2/3 cant: 1 product: to-block mold green_boton2/2 ORDER_ADD_ITEM
cant: 0]
button 0.105.90 green_boton3/1	 [precio: green_boton3/3 cant: 1 product: to-block mold green_boton3/2 ORDER_ADD_ITEM
cant: 0]
button 0.105.90 green_boton4/1	 [precio: green_boton4/3 cant: 1 product: to-block mold green_boton4/2 ORDER_ADD_ITEM
cant: 0]
button 0.105.90 green_boton5/1	 [precio: green_boton5/3 cant: 1 product: to-block mold green_boton5/2 ORDER_ADD_ITEM
cant: 0]
button 0.105.90 green_boton6/1	 [precio: green_boton6/3 cant: 1 product: to-block mold green_boton6/2 ORDER_ADD_ITEM
cant: 0]
button 0.105.90 green_boton7/1	 [precio: green_boton7/3 cant: 1 product: to-block mold green_boton7/2 ORDER_ADD_ITEM
cant: 0]
button 0.105.90 green_boton8/1	 [precio: green_boton8/3 cant: 1 product: to-block mold green_boton8/2 ORDER_ADD_ITEM
cant: 0]
button 0.105.90 green_boton9/1	 [precio: green_boton9/3 cant: 1 product: to-block mold green_boton9/2 ORDER_ADD_ITEM
cant: 0]
button 0.105.90 green_boton10/1	 [precio: green_boton10/3 cant: 1 product: to-block mold green_boton10/2 ORDER_ADD_ITEM
cant: 0]
return
; /// YELLOW
button orange yellow_boton1/1	 [precio: yellow_boton1/3 cant: 1 product: to-block mold yellow_boton1/2 ORDER_ADD_ITEM cant: 0]
button orange yellow_boton2/1	 [precio: yellow_boton2/3 cant: 1 product: to-block mold yellow_boton2/2 ORDER_ADD_ITEM cant: 0]
button orange yellow_boton3/1	 [precio: yellow_boton3/3 cant: 1 product: to-block mold yellow_boton3/2 ORDER_ADD_ITEM cant: 0]
button orange yellow_boton4/1	 [precio: yellow_boton4/3 cant: 1 product: to-block mold yellow_boton4/2 ORDER_ADD_ITEM cant: 0]
button orange yellow_boton5/1	 [precio: yellow_boton5/3 cant: 1 product: to-block mold yellow_boton5/2 ORDER_ADD_ITEM cant: 0]
button orange yellow_boton6/1	 [precio: yellow_boton6/3 cant: 1 product: to-block mold yellow_boton6/2 ORDER_ADD_ITEM cant: 0]
button orange yellow_boton7/1	 [precio: yellow_boton7/3 cant: 1 product: to-block mold yellow_boton7/2 ORDER_ADD_ITEM cant: 0]
button orange yellow_boton8/1	 [precio: yellow_boton8/3 cant: 1 product: to-block mold yellow_boton8/2 ORDER_ADD_ITEM cant: 0]
button orange yellow_boton9/1	 [precio: yellow_boton9/3 cant: 1 product: to-block mold yellow_boton9/2 ORDER_ADD_ITEM cant: 0]
button orange yellow_boton10/1	 [precio: yellow_boton10/3 cant: 1 product: to-block mold yellow_boton10/2 ORDER_ADD_ITEM cant: 0]  
return
; /// BLUE
button  blue_boton1/1	 [precio: blue_boton1/3 cant: 1 product: to-block mold blue_boton1/2 ORDER_ADD_ITEM cant: 0]  
button  blue_boton2/1	 [precio: blue_boton2/3 cant: 1 product: to-block mold blue_boton2/2 ORDER_ADD_ITEM cant: 0]
button  blue_boton3/1	 [precio: blue_boton3/3 cant: 1 product: to-block mold blue_boton3/2 ORDER_ADD_ITEM cant: 0]
button  blue_boton4/1	 [precio: blue_boton4/3 cant: 1 product: to-block mold blue_boton4/2 ORDER_ADD_ITEM cant: 0]
button  blue_boton5/1	 [precio: blue_boton5/3 cant: 1 product: to-block mold blue_boton5/2 ORDER_ADD_ITEM cant: 0]
button  blue_boton6/1	 [precio: blue_boton6/3 cant: 1 product: to-block mold blue_boton6/2 ORDER_ADD_ITEM cant: 0]
button  blue_boton7/1	 [precio: blue_boton7/3 cant: 1 product: to-block mold blue_boton7/2 ORDER_ADD_ITEM cant: 0]
button  blue_boton8/1	 [precio: blue_boton8/3 cant: 1 product: to-block mold blue_boton8/2 ORDER_ADD_ITEM cant: 0]
button  blue_boton9/1	 [precio: blue_boton9/3 cant: 1 product: to-block mold blue_boton9/2 ORDER_ADD_ITEM cant: 0]
button  blue_boton10/1	 [precio: blue_boton10/3 cant: 1 product: to-block mold blue_boton10/2 ORDER_ADD_ITEM cant: 0]
return
; --- finaliza buttons panel ------------------------




; --- Ticket
ticket: list-view 340x300 with [ data-columns: [Producto Cantidad  Total] doubleclick-list-action: [MODIFY_ITEMS]  ]

; --Venta del dia
across

list-view 771x200  with [ data-columns: ["Ticket No." Usuario Fecha Hora Total]]


; -- botones de reporte 

return
button "Corte X Dia" [] 
button "Reporte" [] 
button red "Cancelar" [ticket/data: none ]

text "Total a Pagar " pago_total: field 200x50 font-size 40 bold
button 150x50 "COBRAR" [ ]
return 
text "Diseñado por Valentin Coellar Serrano" 
  ]