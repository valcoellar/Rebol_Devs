rebol [
	Title: "Monkis System Test V1.97"
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



; --------------------- FUNCTION  BOX ---------------

TO_PAY: does [suma: $0 index: 0 foreach item ticket/data [index: index + 1  suma: suma + to-money ticket/data/(index)/3  ]	pago_total/text: to-string  suma show pago_total ]

ORDER_ADD_ITEM: does [total: to-money (precio * cant)  ticket/append-row/values rejoin [ product cant total ]  TO_PAY   ] 

MODIFY_ITEMS: does [bloke: ticket/get-row 	modify:	request rejoin [ "Eliminar esta Producto ? " (to-string bloke/1)] /ok if modify = true [ticket/remove-row ] TO_PAY ]


; ---------------------------------------------------


view layout [size 800x620  backdrop effect [gradient 0x1 orange] 


; --- inicia buttons panel

button red "Hawaiana" 			[precio: 25  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Hawaiana" ORDER_ADD_ITEM if cant = false [print cant]]  
button red "Pollo" 			[precio: 25  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "H. Pollo" ORDER_ADD_ITEM]  
button red "Res" 			[precio: 25  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Res" ORDER_ADD_ITEM] 
button red "Especial" 			[precio: 30  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "H. Especial" ORDER_ADD_ITEM] 
button red "H Combinada" 		[precio: 30  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "H.Combinada " ORDER_ADD_ITEM] 
button red "Com Pollo" 			[precio: 30  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Com. Pollo" ORDER_ADD_ITEM] 
button red "Com Res" 			[precio: 30  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Com. Res" ORDER_ADD_ITEM] 
button red "Com Especial"		[precio: 35  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Com.Especial " ORDER_ADD_ITEM] 

; --- tortss
return

button 0.105.90 "Combinada" 	[precio: 20  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "T.COMBINADA" ORDER_ADD_ITEM]  
button 0.105.90 "HotDog" 	[precio: 12  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "HotDog" ORDER_ADD_ITEM]  
button 0.105.90 "Jamon" 	[precio: 20  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "T. Jamon" ORDER_ADD_ITEM] 
button 0.105.90 "Milanesa" 	[precio: 20  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "T.Milanesa" ORDER_ADD_ITEM] 
button 0.105.90 "Pierna" 	[precio: 20  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "T.Pierna" ORDER_ADD_ITEM] 
button 0.105.90 "Salchicha" 	[precio: 20  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "T.Salchicha" ORDER_ADD_ITEM]
 

;--- Complementos
return

button orange "Papas" 			[precio: 15  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Papas Francsesa" ORDER_ADD_ITEM]

; -- bebidas

return

button "Agua 1/2" 			[precio: 10  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Agua 1/2 Lt " ORDER_ADD_ITEM]  
button "Agua 1Lt" 			[precio: 15  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Agua 1Lt" ORDER_ADD_ITEM]  
button "Coca-Cola" 			[precio: 8  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Cocal-Cola" ORDER_ADD_ITEM] 
button "Fanta" 				[precio: 8  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Fanta" ORDER_ADD_ITEM] 
button "Licuado 1/2" 			[precio: 12  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Licuado 1/2Lt" ORDER_ADD_ITEM] 
button "Licuado 1 Lt" 			[precio: 15  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Licuado 1Lt" ORDER_ADD_ITEM]
button "Pepsi" 				[precio: 8  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1] product: to-block mold "Pepsi" ORDER_ADD_ITEM]  
button "Sprite" 			[precio: 8  cant: to-integer request-text/title "Cantidad: " if cant = 0 [cant: 1]  product: to-block mold "Sprite" ORDER_ADD_ITEM]  

; --- Ticket
return 
ticket: list-view 340x300 with [ data-columns: [Producto Cantidad  Total] doubleclick-list-action: [MODIFY_ITEMS]  ]

; --Venta del dia
across

list-view 771x200  with [ data-columns: ["Ticket No." Usuario Fecha Hora Total]]


; -- botones de reporte 

return
button "Corte X Dia" [] 
button "Corte Y Total" [] 
button "Reporte" []

text "Total a Pagar " pago_total: field 200x50 font-size 40 bold
button 150x50 "COBRAR"
return 
text "Designed By Valentin Coellar Serrano" 
  ]