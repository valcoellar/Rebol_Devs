REBOL [
  Title: "VID LIST-VIEW Face"
  File: %list-view.r
  Author: ["Henrik Mikael Kristensen"]
  Copyright: "2005, 2007 - HMK Design"
  Created: 29-Dec-2005
  Date: 03-Jan-2008
  Version: 0.0.52
  Type: 'include
  Maturity: 'unstable
  Release: 'public
  License: {
    BSD (www.opensource.org/licenses/bsd-license.php)
    Use at your own risk.
  }
  Purpose: {General purpose listview with many features for use in VID.}
  Note: {
    This file is available at:
    http://www.hmkdesign.dk/rebol/list-view/list-view.r
    Demo and testcases available at:
    http://www.hmkdesign.dk/rebol/list-view/list-demo.r
    Docs are available in makedoc2 format at:
    http://www.hmkdesign.dk/rebol/list-view/docs/list-view.txt
    http://www.hmkdesign.dk/rebol/list-view/docs/list-view.html
    http://www.hmkdesign.dk/rebol/list-view/docs/list-view-history.txt
    http://www.hmkdesign.dk/rebol/list-view/docs/list-view-history.html
  }
  History: [
    See: http://www.hmkdesign.dk/rebol/list-view/docs/list-view-history.html
  ]
]

ctx-list: make object! [
  range: make block! []
  old-range: make block! []
  cols: rows: 0
  caret: 1x1
  list: old-col: old-row: none
  qualifiers: none
  shift: control: shift-control: shift-only: control-only: no-qualifiers: none
  hilight-square: make function! [col [integer!] row [integer!]] [
    head for i min old-row row max old-row row 1 [
      insert tail [] head for j min old-col col max old-col col 1 [
        insert tail [] reduce [as-pair j i] ; why? we're not using /only
      ]
    ]
  ]
  
  set-qualifiers: does [
    shift: control: none
    if qualifiers [
      shift: find qualifiers 'shift
      control: find qualifiers 'control
    ]
    qualifiers: none
    shift-control: all [shift control]
    shift-only: all [shift not control]
    control-only: all [not shift control]
    no-qualifiers: all [not shift not control]
  ]

  hilight-cell: make function! [
    col [integer!] row [integer!] /shift /control
  ] [
    insert clear old-range range
    set-qualifiers
    case [
      shift-control [hilight-cell col row]
      shift-only [
        either all [not empty? range old-col old-row] [
          range: hilight-square col row
        ][
          hilight-cell col row
        ]
      ]
      control-only [
        either found? find range as-pair col row [
          remove find range as-pair col row
          old-col: old-row: none
        ][
          insert tail range reduce [as-pair col row]
        ]
      ]
      no-qualifiers [
        not shift not control
        range: reduce [as-pair old-col: col old-row: row]
      ]
    ]
    range
  ]

  hilight-row: make function! [row [integer!] /shift /control] [
    set-qualifiers
    case [
      shift-control [hilight-row row]
      shift-only [
        either all [not empty? range old-row] [
          range: for i min old-row row max old-row row 1 [
            append [] repeat j cols [append [] reduce [as-pair j i]]
          ]
        ][
          hilight-row row
        ]
      ]
      control-only [
        either find range as-pair 1 row [
          repeat i cols [
            attempt [remove find range as-pair i row]
          ] old-row: none
        ][
          insert tail range repeat i cols [append [] reduce [as-pair i row]]
        ]
      ]
      no-qualifiers [
        clear head range
        repeat i cols [insert tail range reduce [as-pair i old-row: row]]
      ]
    ]
    range
  ]

  hilight-column: make function! [col [integer!] /shift /control] [
    set-qualifiers
    case [
      shift-control [hilight-column col]
      shift-only [
        either all [not empty? range old-col] [
          clear range
          for i min old-col col max old-col col 1 [
            repeat j rows [insert tail range reduce [as-pair i j]]
          ]
        ][
          hilight-column col
        ]
      ]
      control-only [
        either find range as-pair old-col: col 1 [
          repeat i rows [attempt [remove find range as-pair col i]]
          old-col: none
        ][
          insert tail range repeat i rows [append [] reduce [as-pair col i]]
        ]
      ]
      no-qualifiers [
        range: repeat i rows [append [] reduce [as-pair old-col: col i]]
      ]
    ]
    range
  ]

  hilight-horizontal: make function! [
    col [integer!] row [integer!] /shift /control
  ] [
    set-qualifiers
    case [
      shift-control [hilight-horizontal col row]
      shift-only [
        either all [not empty? range old-col old-row] [
          set [start end] reduce either old-row >= row [
            either old-col >= col [[
              as-pair col row
              as-pair old-col old-row
            ]][
              either old-row = row [[
                as-pair old-col old-row
                as-pair col row
              ]][[
                as-pair col row
                as-pair old-col old-row
              ]]
            ]
          ][
            ; they are the same?
            either old-col >= col [[
              as-pair old-col old-row
              as-pair col row
            ]][[
              as-pair old-col old-row
              as-pair col row
            ]]
          ]
          range: copy reduce [start]
          unless end = start [
            until [
              start: start + 1x0
              if cols < first start [start: (start * 0x1) + 1x1]
              insert tail range start
              end = start
            ]
          ]
        ][
          hilight-cell col row
        ]
      ]
      control-only [
        either find range as-pair old-col: col old-row: row [
          remove find range as-pair col row
          old-col: old-row: none
        ][
          hilight-cell/control col row
        ]
      ]
      no-qualifiers [hilight-cell col row]
    ]
    range
  ]

  hilight-vertical: make function! [
    col [integer!] row [integer!] /shift /control
  ] [
    set-qualifiers
    case [
      shift-control [hilight-cell col row]
      shift-only [
        either all [not empty? range old-col old-row] [
          set [start end] reduce either old-col >= col [
            either old-row >= row [[
              as-pair col row
              as-pair old-col old-row
            ]][
              either old-col = col [[
                as-pair old-col old-row
                as-pair col row
              ]][[
                as-pair col row
                as-pair old-col old-row
              ]]
            ]
          ][
            ; they are the same?
            either old-row >= row [[
              as-pair old-col old-row
              as-pair col row
            ]][[
              as-pair old-col old-row
              as-pair col row
            ]]
          ]
          range: copy reduce [start]
          unless end = start [
            until [
              start: start + 0x1
              if rows < second start [start: (start * 1x0) + 1x1]
              insert tail range start
              end = start
            ]
          ]
        ][
          hilight-cell col row
        ]
      ]
      control-only [
        either find range as-pair old-col: col old-row: row [
          remove find range as-pair col row
          old-col: old-row: none
        ][
          hilight-cell/control col row
        ]
      ]
      no-qualifiers [hilight-cell col row]
    ]
    range
  ]
]

stylize/master [
  double-arrow: ARROW with [
    size: 20x20
    color: 240.240.240
    colors: none
    font: none
    edge: [size: 1x1]
    init: [
      unless effect [
        state: either all [colors state: pick colors 2] [state] [black]
        effect: compose/deep [
          draw [
            anti-alias off
            pen none
            box 20x20 (either colors [first colors][color])
            fill-pen (state)
            translate 9x9
            polygon 0x-5 5x0 -5x0
            translate 0x5
            polygon 0x-5 5x0 -5x0
          ] rotate (select [up 0 right 90 down 180 left 270] data)
        ]
        state: off
      ]
    ]
  ]

  list-field: BOX with [
    size: 0x20
    edge: make edge [size: 1x1 effect: 'ibevel color: 240.240.240]
    color: 240.240.240
    font: make font [
      size: 11 shadow: none style: none align: 'left color: black
    ]
    para: make para [wrap?: false]
    access: make ctx-access/field []
    flags: [field tabbed return on-unfocus input]
    ; do something in here that will set the field name in list-view
    feel: make ctx-text/edit bind [
      redraw: make function! [face act pos][
        if all [in face 'colors block? face/colors] [
          face/color: pick face/colors face <> view*/focal-face
        ]
      ]
      detect: none
      over: none
      engage: make function! [face act event /local f lv] [
        attempt [lv: get in f: face/parent-face/parent-face 'parent-face]
        switch act [
          down [
            f/focus-column: face/var
            either equal? face view*/focal-face [unlight-text] [
              focus/no-show face
            ]
            view*/caret: offset-to-caret face event/offset
            show face
          ]
          over [
            if not-equal? view*/caret offset-to-caret face event/offset [
              unless view*/highlight-start [
                view*/highlight-start: view*/caret
              ]
                view*/highlight-end: view*/caret:
                  offset-to-caret face event/offset
                show face
              ]
          ]
          key [
            edit-text face event get in face 'action
            finish-edit: make function! [] [
              use f/data-columns compose/deep [
                set [(f/viewed-columns)] f/edt/pane
                f/edit-field: face
                f/focus-column: f/selected-column: face/var
                f/edit-value: get-face face
                ; create a local reference to edit fields here
                if f/tab-edit-action [
                  do bind [(f/tab-edit-action)] f
                ]
                either event/shift [
                  either = 1 length? f/editable-columns [
                    all [<> system/view/focal-face face focus/no-show face]
                  ][
                    if head? find f/editable-columns face/var [
                      focus get last [(f/editable-columns)]
                    ]
                  ]
                ][
                  if tail? next find f/editable-columns face/var [
                    f/pre-submit-edit-func
                    ; ---------- Only hide-edit if the pre-submit-edit-func is not done
                    f/hide-edit
                    all [<> system/view/focal-face f focus/no-show f]
                    f/refresh
                  ]
                ]
              ] true
            ]
            show-f: does bind [filter-list scroll-here place-edit show f] f
            move-line: func [direction] bind [
              if immediate-edit? [
                old-update: update?
                update?: false
                finish-edit
                switch direction [
                  down [next-cnt/act]
                  up [prev-cnt/act]
                ]
                show-edit
                update?: old-update
                update
              ]
            ] f
            switch event/key [
              ; Tab key
              #"^-" [all [f/edt/show? finish-edit show-f]]
              ; Return key
              #"^M" [all [f/edt/show? finish-edit show-f]]
              ; Escape key
              #"^[" [
                if f/edt/show? [
                  f/hide-edit/no-submit
                  show-f
                ]
              ]
              up [move-line 'up]
              down [move-line 'down]
            ]
          ]
        ]
      ]
    ] in ctx-text 'self
  ]
  list-text-box: BOX with [
    size: 0x20
    font: make font [
      size: 11 shadow: none style: none align: 'left color: black
    ]
    para: make para [wrap?: false]
    flags: [text]
    truncated?: false
    full-text: none
    pane: none
    feel: make feel [
      engage: make function! [face act evt] []
    ]
  ]
  list-text: LIST-TEXT-BOX with [
    select-func: make function! [
      face [object!] evt lv [object!] face-data [integer!] /local pos
    ] [
      lv/mouse?: true
      pos: as-pair index? find face/parent-face/pane face face-data
      lv/selected-column: pick lv/viewed-columns first pos
      lv/old-sel-cnt: lv/sel-cnt
      lv/sel-cnt: lv/cursor/y: face-data
      lv/context-list/qualifiers: make block! []
      ; this does not work on OSX for some reason
      if evt/shift [insert tail lv/context-list/qualifiers 'shift]
      if evt/control [insert tail lv/context-list/qualifiers 'control]
      if all [lv/sel-cnt lv/selected-column] [
        lv/context-list/old-range: copy lv/context-list/range
        switch lv/select-mode bind [
          single [
            context-list/qualifiers: none
            context-list/hilight-cell col-idx selected-column sel-cnt
          ]
          single-row [
            context-list/qualifiers: none
            context-list/hilight-row sel-cnt
          ]
          multi [
            context-list/hilight-cell col-idx selected-column sel-cnt
          ]
          multi-row [context-list/hilight-row sel-cnt]
          column [context-list/hilight-column col-idx selected-column]
          horizontal [
            context-list/hilight-horizontal
              col-idx selected-column sel-cnt
          ]
          vertical [
            context-list/hilight-vertical
              col-idx selected-column sel-cnt
          ]
        ] lv ; bind to context-list as well?
      ]
    ]
    feel: make feel [
      over: make function! [face ovr /local f lv pos] [
        error? try [lv: get in f: face/parent-face/parent-face 'parent-face]
        if all [ovr f not lv/scrolling?] [
          lv/over-cell-text: face/full-text
          lv/over-data: face/data
          lv/over-row: face/row
          all [
            lv/over-row-action
            use lv/data-columns [
              set bind lv/editable-columns lv lv/edt/pane
              do bind lv/over-row-action lv
            ]
          ]
          if face/truncated? [
            ; Show tool tip
          ]
;         if face/data [
;           change back tail pick lv/data face/data now/time/precise
;           lv/lst/pane lv/lst face/data
;           face/color: random 255.255.255
;           pick lv/data face/data
;           show lv/lst/subface
;         ]
        ]
;        either all [
;          ovr lv/ovr-cnt <> face/data; long-enough
;        ][
;          lv/ovr: true
;          f/parent-face/ovr-cnt: face/data
;          ; delay-show f
;        ][lv/ovr: none]
      ]
      engage: make function! [
        face act evt
        /local f lv p1 p2 r fd qualifiers old-update tmp-offset changed
        scrolled?
      ] [
        attempt [lv: get in f: face/parent-face/parent-face 'parent-face]
        fd: any [face/data none]
        if all [
          f
          lv
          lv/lock-list = false
          find [down alt-down] act
          face
        ][
          start-offset: evt/offset
          old-update: lv/update?
          lv/update?: false
          if all [lv/editable? lv/edt/show?] [
            lv/pre-submit-edit-func
            lv/hide-edit
            lv/filter-list
            all [<> system/view/focal-face lv focus/no-show lv]
          ]
          ; ---------- LIST-ACTION vs. EMPTY-ACTION
          ; needs to work both on columns and rows
;          changed: not found? find lv/range-rows fd
          changed: true
          either fd [
            if changed [select-func face evt lv fd]
            switch act [
              down [
                unless lv/redraggable-rows [
                  lv/do-action 'list-action
                ]
              ]
              alt-down [lv/do-action 'alt-list-action]
            ]
          ][
            unless lv/keep-selected [lv/reset-sel-cnt]
            switch act [
              down [lv/do-action 'empty-action]
              alt-down [lv/do-action 'alt-empty-action]
            ]
          ]
          if all [
            not lv/lock-list fd lv/editable? lv/edt/show? lv/immediate-edit?
          ] [lv/show-edit]
          if all [lv/lock-list = false evt/double-click] [
            either fd [
              all [
                lv/sel-cnt
                lv/do-action 'doubleclick-list-action
              ]
            ][
              lv/do-action 'doubleclick-empty-action
            ]
            if all [fd lv/editable? not lv/immediate-edit?] [
              lv/show-edit
            ]
          ]
          lv/update?: old-update
          all [
            not lv/edt/show?
            not lv/dragging?
            any [
              changed
              lv/focus-list/no-show
            ]
            ; this shows the list
            either system/view/focal-face <> lv [
              focus lv
            ][
              any [lv/refresh show lv/lst]
            ]
          ]
        ]
        if act = 'up [
          ; this operation must also be done inside drg-face, if
          ; we want a drg-face to be shown, otherwise we'll lose events.

          if all [lv/redraggable-rows not lv/edt/show?] [
            all [
              <> system/view/focal-face
              lv
              any [
                all [
                  lv/auto-focus
                  system/view/focal-face <> lv
                  focus/no-show lv
                ]
                show lv/lst
              ]
            ]
            lv/do-action 'list-action
          ]
          if lv/dragging? [
            lv/dragging?: none
            use [old-update from-row to-row] [
              if lv/drgm/show? [
                old-update: lv/update?
                lv/update?: false
                if not empty? lv/range-func [
                  to-row: second lv/drgm/offset + 1 / lv/row-height + lv/cnt
                  lv/move-row
                    from-row: switch lv/select-mode [
                      single-row [
                        first lv/range-func
                      ]
                      multi-row [
                        lv/range-func
                      ]
                    ]
                    to-row: to-row - pick [1 0] to-row > from-row
                ]
                hide lv/drgm
;                hide lv/drg
                lv/drgm/offset/y: 0
                lv/set-sel-cnt to-row
                lv/update?: old-update
                lv/update
                lv/do-action 'drop-action
              ]
            ]
          ]
          row: face/row
        ]
        if all [act = 'alt-up find lv/range-func face/data] [
          lv/do-action 'alt-list-action
        ]
        if all [
          lv/redraggable-rows not lv/lock-list 'move = evt/type
          1 < length? lv/data
        ] [
          if all [
            evt/offset/y >= 0 evt/offset/y < lv/row-height
            not empty? lv/range-func
          ] [
            lv/over-row: first lv/range-func
          ]
          offset: evt/offset - start-offset
          if all [
            fd
            any [lv/dragging? 8 < abs offset/x 8 < abs offset/y]
          ] [
            lv/dragging?: true
            tmp-offset: 0x0
            tmp-offset/y:
              subtract
                round/to/floor
                  min
                    min lv/size/y lv/value-size + 1 * lv/row-height
                    max
                      lv/hdr/size/y
                      evt/offset/y + face/parent-face/offset/y +
                      lv/hdr/size/y + / lv/row-height 2
                  lv/row-height
                1
            lv/drg/offset: as-pair evt/offset/x - (lv/drg/size/x / 2)
              evt/offset/y + face/parent-face/offset/y + lv/hdr/size/y -
              / lv/drg/size/y 2
            if lv/drgm/offset/y <> tmp-offset/y [
              hide lv/drgm
              lv/drgm/offset/y: tmp-offset/y
            ]

            ; drag-move the list if it's bigger than the view
            if all [
              lv/value-size > lv/list-size
            ] [
              all [
                lv/hdr/size/y > lv/drgm/offset/y
                lv/cnt > 0
                lv/update-speed: lv/drag-speed + 0:00:00.05
                lv/long-enough
                do-face lv/scr/pane/2 none
                scrolled?: true
              ]
              all [
                lv/drgm/offset/y > subtract lv/size/y lv/row-height
                lv/cnt < subtract lv/value-size lv/list-size
                lv/update-speed: lv/drag-speed + 0:00:00.05
                lv/long-enough
                do-face lv/scr/pane/3 none
                scrolled?: true
              ]
            ]
            if any [
              lv/drgm/offset/y <> lv/drgm/old-offset/y
              scrolled?
            ] [
              lv/drgm/old-offset: lv/drgm/offset
              show lv/drgm
            ]
          ]
        ]
      ]
    ]
    data: row: 0
  ]
  list-view: FACE with [
    hdr: hdr-btn: hdr-fill-btn: hdr-corner-btn:
    lst: lst-fld: scr: edt: pup: pdn: hscr: drgm: drg:
    hdr-face: hdr-btn-face: hdr-fill-btn-face: hdr-corner-btn-face: 
    lst-face: lst-fld-face: scr-face: edt-face: page-scr-face: drg-face: none
    edged-size: size: 300x200
    drag-speed: 0:00:0.05
    dirty?: fill: true
    click: none
    colors: [
      even              240.240.240
      odd               220.230.220
      select-focus      180.200.180
      select-unfocus    180.180.180
      background        140.140.140
      header-fill       120.120.120
      header-background 140.140.140
      header-inactive   140.140.140
      header-active     155.155.155
      glyph             200.200.200
      list-edge         140.140.140
      edit-field        240.240.240
      drag-edge         100.100.100
      marker            0.0.0
    ]
    edge: make edge [size: 0x0 color: colors/list-edge effect: 'ibevel]
    column-face: make face [
      edge: text: effect: none
      offset: 1x1
    ]
    button-edge: make edge [
      size: 1x1 color: colors/list-edge effect: 'bevel
    ]
    drag-edge: make edge [
      size: 1x0 color: colors/drag-edge effect: none
    ]
    color: make function! [] [select colors either fill ['even]['background]]
    spacing-color: make function! [] [colors/select-focus]
    select-color: make function! [] [colors/select-focus]
    old-data-columns: copy data-columns: copy indices: copy conditions: []
    even-odd-colors:
    old-viewed-columns: viewed-columns: header-columns:
    readonly-columns: editable-columns:
    hidden-column:
    old-widths: widths: px-widths: px-offsets:
    old-fonts: fonts:
    old-paras: paras:
    over-cell-text: over-data: over-row:
    limit: types: none
    truncate: drag: fixed: console: false
    fit: true
    scroller-width: row-height: 20
    vo-set: 0
    col-widths: h-fill: 0
    spacing: 0x0
    data: copy []
    resize-column: selected-column: sort-column: old-sort-column: none
    readonly-columns: copy []
    mouse?:
    editable?: immediate-edit?: redraggable-columns: redraggable-rows:
    h-scroll: page-scroll: false
    resizable-columns?: update?: true
    old-edit: last-edit: none
    sort-index: copy []
    sort-modes: copy [asc desc nosort]
    sort-method: copy []
    allow-sorting: true
    allow-sort-func: make function! [] [all [allow-sorting not lock-list]]
    sort-direction: copy []
    tri-state-sort: paint-columns: false
    group-rows-by: none
    select-modes: [
      single
      multi
      single-row
      multi-row
      column
      horizontal
      vertical
    ]
    select-mode: third select-modes
    drag-modes: [drag-select drag-move]
    drag-mode: first drag-modes
    variable-height: false
    list-focus: false
    auto-focus: true
    ovr-cnt: old-sel-cnt: sel-cnt: none
    cnt: ovr: old-ovr: 0
    then: now/time/precise
    update-speed: 0:00:00
    keep-selected: true
    cell: cells: none
    row: none
    idx: 1
    lock-list:
    debug: debug-redraw: false
    follow?: true
    row-face:
    context-list:
    block-data?: object-data?: default-object: none
    standard-font: make system/standard/face/font [
      size: 11 shadow: none style: none align: 'left color: black
    ]
    standard-para: make system/standard/face/para [wrap?: false]
    standard-header-font: make standard-font [
      size: 12 shadow: 0x1 color: white
    ]
    standard-header-para: make standard-para []
    acquire-func: []
    list-size: value-size: 0
    cursor: 1x1
    o-size: 0

    ; Updating functions

    resize: make function! [sz] [
      calc-px-values
      size: sz
      refresh
    ]
    update-pair: make function! [from to] [
      lst/single: from
      show lst/subface
      lst/single: to
      show lst/subface
    ]
    follow: make function! [/pair from to] [
      either follow? [scroll-here][
        either pair [update-pair from to][all [update? show lst]]
      ]
    ]

    access: make object! [
      set-face*: func [face value] [
        if any [block? value none? value] [
          face/reset-sel-cnt
          clear face/data
          clear face/sort-index
          insert face/data value
          ; method to update the columns if the number of columns has changed
          face/update
        ]
      ]
      get-face*: func [face] [
        face/data
      ]
      clear-face*: func [face] [
        face/reset-sel-cnt
        clear face/data
        clear face/sort-index
        face/update
      ]
    ]

    ; Actions and related variables
    
    edit-value: edit-index: edit-field: focus-column: none

    list-action: over-row-action: alt-list-action: doubleclick-list-action:
      empty-action: alt-empty-action: doubleclick-empty-action: key-action:
      edit-action: tab-edit-action: pre-submit-edit-action: row-action:
      refresh-action: sort-action: drop-action: cancel-edit-action:
      submit-edit-action: none

    actions: [
      list-action
      over-row-action
      alt-list-action
      doubleclick-list-action
      empty-action
      alt-empty-action
      doubleclick-empty-action
      key-action
      edit-action
      tab-edit-action
      pre-submit-edit-action
      submit-edit-action
      cancel-edit-action
      row-action
      refresh-action
      sort-action
      drop-action
    ]

    do-action: make function! [action-name [word!] /no-select /local err] [
      either find actions action-name [
        mouse?: false
        if either no-select [
          all [
            block? get in self action-name
            not empty? get in self action-name
          ]
        ][
          all [
            any [
              ;all [sel-cnt not empty? sort-index]
              ; perhaps better 'pick data row' detection, as get-range relies on this
              all [not empty? data not empty? get-range not empty? sort-index]
              ; Actions that require a selected row are listed here
              not found? find [
                list-action
                alt-list-action
                doubleclick-list-action
                edit-action
                tab-edit-action
                pre-submit-edit-action
                submit-edit-action
              ] action-name
            ]
            get in self action-name
          ]
        ] [
          do bind get in self action-name 'self
        ]
      ][
        make error! reform ["No such action:" action-name]
      ]
    ]

    pre-submit-edit-func: make function! [] [
      use data-columns compose/deep [
        if all [edt/show? pre-submit-edit-action] [
          set [(viewed-columns)] edt/pane
          do bind [(pre-submit-edit-action)] 'self
        ]
      ]
    ]

    submit-edit-func: make function! [] [
      use data-columns compose/deep [
        if all [edt/show? submit-edit-action] [
          set [(viewed-columns)] edt/pane
          do bind [(submit-edit-action)] 'self
        ]
      ]
    ]

    ; List Imaging

    create-column-image: func [hdr-face] [ 
      copy/part skip to-image self hdr-face/offset
        as-pair hdr-face/size/x self/size/y
    ]

    create-row-image: func [row-face] [
      to image! self
    ]

    ; List Dimensions

    value-size: make function! [/local l] [
      l: either block? data [
        length?
          either all [empty? filter-specs empty? filter-string] [
            data
          ][
            either empty? filter-index [[]][sort-index]
          ]
      ][
        0
      ]
      any [all [limit min l limit] l]
    ]

    list-size: make function! [/local l-size] [
      to integer! divide lst/size/y lst/subface/size/y
    ]

    ; Calcs px-widths px-offsets col-widths h-fill

    calc-px-values: has [resize-column-index resize-width] [
      px-widths: copy widths
      px-offsets: copy [0]
      repeat i length? widths [
        if decimal? pick widths i [
          poke px-widths i to integer! size/x - scr/size/x * pick widths i
        ]
      ]
      resize-width: edged-size/x - scroller-width
      col-widths: do replace/all trim/with mold px-widths "[]" " " " + "
      either fit [
        resize-column-index: any [
          attempt [index? find viewed-columns resize-column] 1
        ]
        repeat i length? px-widths [
          all [
            resize-column-index <> i
            resize-width: resize-width - pick px-widths i
          ]
        ]
        change at px-widths resize-column-index resize-width
      ][
        if col-widths < resize-width [
          insert tail px-widths h-fill: resize-width - col-widths
        ]
      ]
      repeat i length? px-widths [
        insert tail px-offsets add pick px-widths i pick px-offsets i
      ]
    ]
    
    ; List Face Layout

    lst-lo: make function! [/local lo sp] [
      lst/subface: layout/tight either row-face [row-face][
        lo: copy compose [across space 0 pad (as-pair 0 spacing/y)]
        repeat i length? viewed-columns [
          sp: either i = length? viewed-columns [0][spacing/x]
          insert tail lo compose [
            list-text (as-pair subtract pick px-widths i sp row-height)
            pad (as-pair sp 0)
          ]
        ]
        if h-fill > 0 [
          insert insert tail lo 'list-text as-pair h-fill row-height
        ]
        lo
      ]
      either row-face [row-height: lst/subface/size/y][
        fonts: reduce fonts
        paras: reduce paras
        repeat i length? lst/subface/pane [
          lst/subface/pane/:i/font: make standard-font
            either i > length? fonts [last fonts][pick fonts i]
          lst/subface/pane/:i/para: make standard-para
            either i > length? paras [last paras][pick paras i]
        ]
      ]
      lst/subface/color: spacing-color
      cells: copy viewed-columns
      repeat i subtract length? lst/subface/pane either fit [0][1] [
        insert next find cells pick viewed-columns i pick lst/subface/pane i
      ]
    ]

    ; List Focusing
    ; this type of focusing is independant from VID focusing.
    ; they should probably be synchronized.

    set-focal-face: make function! [f] [
      all [<> system/view/focal-face f focus/no-show f]
    ]

    focus-list: make function! [/no-show] [
      unless list-focus [
        list-focus: true
        select-color: colors/select-focus
        ; perhaps set-focal-face instead?
        unless no-show [refresh]
        sel-cnt
      ]
    ]
    unfocus-list: make function! [/no-show] [
      if list-focus [
        list-focus: false
        select-color: colors/select-unfocus
        any [no-show do [hide-edit/no-submit refresh]]
        sel-cnt
      ]
    ]

    ; Configuration Importing and Exporting (unfinished)
    
    import: make function! [data [object!]] [
    ]

    export: make function! [] [
      make object! third self
    ]

    ; navigation functions

    ; behaviour table
    
    ; do this in ctx-list?

    do-cnt: make function! [/act] [
      switch select-mode [
        single [
          ; we need behaviour for every single make function
        ]
        single-row []
        multi []
        multi-row []
        column []
        horizontal []
        vertical []
      ]
    ]
    act-cnt: make function! [act] [
      if act [do-action 'list-action]
      sel-cnt
    ]

    first-cnt: make function! [/act] [
      re-sort
      old-sel-cnt: sel-cnt
      set-sel-cnt either empty? sort-index [none][first sort-index]
      follow
      act-cnt act
    ]
    prev-page-cnt: make function! [/act] [
      prev-cnt/skip-size list-size
      act-cnt act
    ]
    prev-cnt: make function! [/act /skip-size size /local f sz si] [
      re-sort
      sz: negate either skip-size [size][1]
      set-sel-cnt either empty? sort-index [none][
        all [
          f: find sort-index sel-cnt
          not empty? si: skip f sz first si
        ]
      ] follow
      act-cnt act
    ]
    next-cnt: make function! [/act /skip-size size /local f sz si] [
      re-sort
      sz: either skip-size [size][1]
      set-sel-cnt either empty? sort-index [none][
        either all [
          f: find sort-index sel-cnt
          not empty? f: skip f sz
        ] [
          first f
        ][
          either block? f [
            either tail? f [last sort-index][sel-cnt]
          ][
            first sort-index
          ]
        ]
      ] follow
      act-cnt act
    ]
    next-page-cnt: make function! [/act] [
      next-cnt/skip-size list-size
      act-cnt act
    ]
    last-cnt: make function! [/act] [
      re-sort
      set-sel-cnt either empty? sort-index [none][last sort-index]
      follow
      act-cnt act
    ]
    max-cnt: make function! [/act] [
      re-sort
      set-sel-cnt either empty? sort-index [none][first maximum-of sort-index]
      follow
      act-cnt act
    ]
    min-cnt: make function! [/act] [
      re-sort
      set-sel-cnt either empty? sort-index [none][first minimum-of sort-index]
      follow
      act-cnt act
    ]
    limit-sel-cnt: make function! [] [
      if all [sel-cnt not found? find sort-index sel-cnt] [last-cnt] sel-cnt
    ]
    set-sel-cnt: make function! [id [integer! none!]] [
      either all [sel-cnt: id sel-cnt: max 0 id] [
        context-list/hilight-row id
      ][
        context-list/range: copy []
      ]
    ]
    reset-sel-cnt: make function! [] [ovr-cnt: set-sel-cnt none mouse?: false]
    selected?: make function! [] [not none? sel-cnt]
    tail-cnt?: make function! [/local val] [
      all [
        sel-cnt
        val: find sort-index sel-cnt
        equal? index? val length? sort-index
      ]
    ]
    head-cnt?: make function! [] [sel-cnt = first sort-index]
    tail-cnt?: make function! [] [sel-cnt = last sort-index]

    ; column functions

    insert-column: make function! [
      pos [integer!] names [string! word! block!] /invisible
    ] [
      if block-data? [
        names: to-block names
        foreach n names [
          insert at data-columns pos to word! n
          any [invisible insert at viewed-columns pos to word! n]
          any [invisible insert at header-columns pos to string! n]
          repeat row data [insert at row pos none]
        ]
        update/force
      ]
    ]
    append-column: make function! [names [string! word! block!] /invisible] [
      do either invisible [
        'insert-column/invisible
      ][
        'insert-column
      ] 1 + length? data-columns names
    ]
    update-column: make function! [
      old-name [string! word!] new-name [string! word!]
      /header header-name [string!]
    ] [
      replace data-columns to word! old-name to word! new-name
      replace viewed-columns to word! old-name to word! new-name
      either header [
        all [
          find viewed-columns new-name
          change
            at
              header-columns
              index? find viewed-columns new-name
            header-name
        ]
      ][
        replace header-columns to string! old-name to string! new-name
      ]
      update/force
    ]
    remove-column: make function! [names [string! word! block!] /local i] [
      names: to block! names
      foreach n names [
        n: to word! n
        remove i: find data-columns to word! n
        remove find viewed-columns to word! n
        remove find header-columns to string! n
        repeat row data [remove at row index? i]
      ]
      update/force
    ]

    ; searching functions
    
    ; already obsolete!!
    
    search: make function! [value /part /column col [word!] /local i j out] [
      out: 0
      either block-data? [
        either column [
          i: index? find data-columns col
          either part [
            repeat j length? data [
              all [
                found? find to string! pick pick data j i value out: j break
              ]
            ]
          ][
            repeat j length? data [
              all [value = pick pick data j i out: j break]
            ]
          ]
        ][
          either part [
            repeat j length? data [
              repeat l length? pick data j [
                all [
                  found? find to string! pick pick data j l value out: j break
                ]
              ]
            ]
          ][
            repeat j length? data [
              all [found? find pick data j value out: j break]
            ]
          ]
        ]
      ][
        either part [
          repeat j length? data [
            all [found? find pick data j value out: j break]
          ]
        ][
          out: index? find data value
        ]
      ] either = 0 out [none][get-row/raw out]
    ]

    ; filtering functions

    old-filter-string: copy filter-string: copy ""
    filter-pos: make function! [pos] [attempt [index? find sort-index pos]]
    filter-sel-cnt: make function! [] [all [sel-cnt filter-pos sel-cnt]]
    filter-specs: copy filter-index: copy sort-index: copy []

    filter-row: make function! [
      row [block!] spec-block [block!]
      /local id ids string indices out sp
    ] [
      string: first back indices: next second spec-block
      out: either all [series? string empty? string] [
        true
      ][
        either empty? indices [
          unless found? find first spec-block 'only [row: to string! row]
          found? find row string
        ][
          ids: make list! []
          sp: make list! []
          ; this should be moved to filter-rows,
          ; as it can be precalculated outside this
          repeat i indices [
            all [id: find data-columns i insert ids index? id]
          ]
          found? find either find first spec-block 'only [
            head repeat i head ids [insert sp pick row i]
          ][
            to string! head repeat i head ids [insert sp pick row i]
          ] string
        ]
      ]
      either find first spec-block 'not [system/words/not out][out]
    ]

    filter-rows: make function! [/local filter-index fs fstrs] [
      filter-index: make list! []
      data-columns: to-hash data-columns
      fs: extract filter-specs 3
      ; can we actually parse this? or parse filter-specs?
      fstrs: make hash! []
      repeat f fs [
        insert/only tail fstrs copy/part next find filter-specs f 2
      ]
      repeat i length? data [
        all [
          repeat fstr fstrs [
            any [filter-row pick data i fstr break/return false]
          ]
          insert filter-index i
        ]
      ]
      data-columns: to-block data-columns
      copy to block! head filter-index
    ]

    set-filter-spec: make function! [
      name [word!] value columns [block!] /only /not
      /local spec-block params
    ] [
      cnt: 0
      params: copy []
      if only [insert tail params 'only]
      if not [insert tail params 'not]
      spec-block: reduce [params head insert tail reduce [value] columns]
      either select filter-specs name [
        change next find filter-specs name spec-block
      ][
        insert tail head insert tail filter-specs name spec-block
      ]
      refresh
    ]

    remove-filter-spec: make function! [name] [
      remove/part find filter-specs name 3 refresh
    ]

    reset-filter-specs: make function! [] [filter-specs: copy [] refresh]

    filter: make function! [/local default-i i w str result g-length g] [
      either empty? filter-specs [
        ;filter-index: clear head filter-index
        filter-index: make list! []
        either none? data [make block! []][
          g-length: length? g: to hash! parse to string! filter-string none
          either g-length > 0 [
            ; the size of the bitset must be multipliable by 8
            result: (power 2 g-length) - 1
            i: 0
;            result: copy i: copy
;              default-i: make bitset! (g-length + 8 - (g-length // 8))
;            w: 1
;            until [
;              insert result w
;              w: w + 1
;              w > g-length
;            ]
            ; handle index skipping here
            repeat j length? data [
              i: 0
              str: form pick data j
              ; handle column distinction here
              repeat num g-length [
                all [find str pick g num i: i + power 2 (num - 1)]
              ]
              all [i = result insert filter-index j]
            ]
            filter-index: to block! head filter-index
          ][make block! []]
        ]
      ][filter-index: filter-rows]
    ]

    scrolling?: dragging?: none
    list-sort: make function! [/local k i vals od] [
      either sort-column [
        od: object-data?
        vals: make block! length? data
;        i: col-idx/viewed sort-column
        k: col-idx sort-column
        either block-data? [
          either object-data? [
            repeat j length? data [
              insert/only
                insert
                  insert tail
                    vals
                      pick next second pick data j k
                    j
                    next second pick data j
              ;insert tail vals reduce [
              ;  pick next second pick data j k
              ;  j
              ;  next second pick data j
              ;]
            ]
          ][
            repeat j length? data [
              insert/only insert insert tail vals pick pick data j k j copy pick data j
            ]
          ]
        ][
          either od [
            repeat j length? data [
              insert/only insert insert/only tail vals next second pick data j j next second pick data j
            ]
          ][
            repeat j length? data [
              insert insert insert tail vals pick data j j pick data j
            ]
          ]
        ]
        vals: head vals
        ; needs to support sort/compare
        sort-index: extract/index switch/default pick sort-direction k [
          asc [sort/skip vals 3]
          desc [sort/skip/reverse vals 3]
        ][vals] 3 2
      ][
        clear sort-index
        if all [not none? data any-block? data not empty? data] [
          repeat i length? data [insert tail sort-index i]
        ]
        sort-index
      ]
    ]
    re-sort: make function! [] [
      all [
        not empty? sort-index
        not-equal? value-size first maximum-of sort-index
        ; list-sort ; doesn't work when filtering!
        filter-list
      ]
    ]
    reset-sort: make function! [/local old-update] [
      sort-column: none
      ; convert to block
;      sort-direction: array/initial length? viewed-columns 'nosort
      sort-direction: array/initial length? data-columns 'nosort
      list-sort
      repeat p hdr/pane [if p/style = 'hdr-btn [p/effect: none]]
      old-update: update?
      update?: false
      refresh
      update?: old-update
      follow
    ]
    set-sorting: make function! [column [word!] direction [word!]] [
      unless empty? sort-direction [
        sort-column: column
        change at sort-direction col-idx column direction
        if allow-sort-func [
;          change at sort-direction col-idx/viewed column direction
          set-header-buttons
        ]
        ; refresh/force would crash this. why?
        refresh
      ]
    ]
    set-sort-method: make function! [column [word!] method [block!]] [
      
    ]
    reset-sort-method: make function! [] [
      
    ]
    
    ; ---------- Header Buttons

    set-header-buttons: make function! [] [
      any [allow-sort-func return false]
      repeat button hdr/pane [
        unless 'hdr-corner-btn = button/style [
          button/effect: either all [sort-column button/var = sort-column] [
;            switch/default pick sort-direction col-idx/viewed sort-column [
            switch/default pick sort-direction col-idx sort-column [
              asc [head insert tail copy button/eff-blk 1x1]
              desc [head insert tail copy button/eff-blk 1x0]
            ][none]
          ][none]
          button/color: either all [
            sort-column button/var = sort-column
          ] [colors/header-active][colors/header-inactive]
        ]
      ]
      set-corner-glyph
      show hdr
    ]
    set-corner-glyph: make function! [/local glyph-scale glyph-adjust] [
      glyph-scale: (min scroller-width hdr/size/y) / 3
      glyph-adjust: as-pair scroller-width / 2 - 1 hdr/size/y / 2 - 1
      unless empty? hdr/pane [
        set in last hdr/pane 'effect
          either allow-sort-func [
            compose/deep
            [draw [
              (either 1.3.0.0.0 <= system/version [[anti-alias off]][])
              translate (glyph-adjust)
              pen none fill-pen (colors/glyph) polygon
              (0x-1 * glyph-scale) (1x0 * glyph-scale)
              (compose either filtering? [
                ; ---------- Filtered Glyph
                [(-1x0 * glyph-scale) (0x1 * glyph-scale)]
              ][
                ; ---------- Unfiltered Glyph
                [(0x1 * glyph-scale) (-1x0 * glyph-scale)]
              ])
            ]]
          ][none]
      ]
    ]
    filtering?: make function! [] [
      any [
        not empty? filter-string
        not empty? any [
          foreach s extract/index filter-specs 3 3 [append "" first s]
          ""
        ]
      ]
    ]
    filter-list: make function! [/full /single id] [
      either any [sort-column not single] [
        sort-index: either empty? filter [
          either any [
            dirty? all [empty? filter-specs empty? filter-string]
          ] [
            dirty?: false
            list-sort
          ][
            copy []
          ]
        ][
        ; remove this line if things don't break
;          if value-size <= list-size [cnt: 0]
          old-filter-string: copy filter-string
          list-sort
          intersect sort-index filter-index
        ]
        if limit [sort-index: copy/part sort-index limit]
;        all [filtering? not found? find sort-index sel-cnt reset-sel-cnt]
        all [not found? find sort-index sel-cnt reset-sel-cnt]
        context-list/rows: length? sort-index
        set-scr
        either full [
          refresh ; risk of recursion if refresh ever uses filter-list/full
        ][
          ; this causes double show when used in refresh, so check
          ; the dirty? flag
          if all [update? dirty?] [show [lst scr]]
        ]
      ][
        lst/single: id
        if update? [show lst/subface]
        ; look at the part where single: none in the lst/pane code!
      ] true
    ]
    set-filter: make function! [string [string!]] [
      cnt: 0
      filter-string: copy string
      refresh
    ]
    reset-filter: make function! [] [
      old-filter-string: copy filter-string: copy ""
      refresh
    ]
    set-limit: make function! [size [integer!]] [
      limit: size
      cnt: 0
      refresh
    ]
    reset-limit: make function! [] [limit: none cnt: 0 refresh]
    scroll-here: make function! [/local sl old-cnt] [
      old-cnt: cnt
      if all [
        sel-cnt
        not empty? sort-index
        not found? find [column multi multi-row] select-mode
      ] [
        limit-sel-cnt
        sl: index? find sort-index sel-cnt
        cnt: min sl - 1 cnt
        cnt: (max sl cnt + list-size) - list-size

        ; causes a bug during move-row up from the last row
        ; because it assumes that we have removed a row.
        ; value size is not being handled correctly externally

        if list-size < length? sort-index [
          cnt: (min cnt + list-size value-size) - list-size
        ]

        cnt: max 0 cnt
        if old-cnt <> cnt [
          set-scr
          move-edit
        ]
        if update? [show [lst scr]]
      ]
    ]
    set-scr: make function! [/local old-update] [
      scr/redrag list-size / max 1 value-size
      scr/data: either value-size = list-size [0][
        cnt / (value-size - list-size)
      ]
      if console [scr/data: 1 - scr/data]
    ]
    place-edit: make function! [/local idx] [
      idx: either sort-column [index? find sort-index sel-cnt][sel-cnt]
      edt/offset/y: (any [idx 0]) - cnt - 1 * lst/subface/size/y + hdr/size/y
    ]
    move-edit: make function! [] [
      if edt/show? [
        edt/offset/y: either zero? sel-cnt - cnt [
          negate edt/size/y
        ][
          lst/subface/size/y * (sel-cnt - cnt)
        ]
        show edt
      ]
    ]
    long-enough: make function! [] [
      time? all [
        greater? absolute
          now/time/precise - then update-speed then: now/time/precise
      ]
    ]

    ; data retrieval functions

    check-column: make function! [col [word! integer!] func-block [block!]] [
      either any [
        integer? col
        find data-columns col
      ] [
        do func-block
      ][
        make error! reform ["Column" col "does not exist"]
      ]
    ]
    sorted-data: make function! [/local out j] [
      out: make list! []
      j: either limit [min limit length? sort-index][length? sort-index]
      repeat i j [insert/only out pick data pick sort-index i]
      to block! head out
    ]
    totals: make function! [] [
      as-pair
        any [all [limit min limit length? sort-index] length? sort-index]
        length? data
    ]
    get-id: make function! [pos rpos h r /inserting] [
      either r [rpos][either h [filter-pos pos][any [sel-cnt 1]]]
    ]
    row-obj: make function! [] [
      make object! head insert tail repeat c data-columns [
        insert tail [] to set-word! either block-data? [c][first parse c none]
      ] reduce ['copy copy ""]
    ]
    ; needs to be fixed for new modes including multi-row
    ; currently it will only get the row that is selected with sel-cnt
    get-row: make function! [
      /over /range /here pos /raw rpos /keys /local id obj
    ] [
      id: get-id pos rpos here raw
      either id [
        either all [keys not object-data?] [
          obj: make row-obj []
          set obj pick data id obj
        ][
          pick data id
        ]
      ][
        pick data either over [over-data][id]
      ]
    ]
    get-range: make function! [/flat /vertical /local out y bd od block] [
      out: copy []
      bd: block-data?
      od: object-data?
      ; we should worry about the select mode in GET-RANGE
      either any [flat find [horizontal vertical] select-mode] [
        repeat c context-list/range [
          insert tail out pick pick data second c first c
        ]
      ][
        unless empty? y: context-list/range [
          block: make block! length? y
          until [
            clear block
            until [
              ; first get the row number
              row: second first y
              ; append the pair! to the block
              insert tail block either all [bd not od] [
                ; for 2D lists
                pick pick data row first first y
              ][
                ; for single column lists and object lists
                pick data row
              ]
              ; go to next pair!
              y: next y
              ; end block if y is tail or new row
              any [
                tail? y
                row <> second first y
              ]
            ]
            ; ok so this doesn't work for objects
            ; since the object list
            either bd [
              either od [
                insert tail out first block
              ][
                insert/only tail out copy block
              ]
            ][
              insert tail out block
            ]
            tail? y
          ]
        ]
      ] out
    ]
    ; what if we want the range diff to be done inside the list-action?
    range-added: make function! [] [exclude context-list/range context-list/old-range]
    range-removed: make function! [] [exclude context-list/old-range context-list/range]
    find-row: make function! [
      value /col colname /act /wild /local c d i j fnd? cell
    ] [
      i: 0
      fnd?: false
      either empty? data [none][
        either col [
          c: col-idx colname
          until [
            i: i + 1
            any [
              not object? d: pick data i
              d: next second d
            ]
            cell: pick d c
            any [
              all [i = length? data cell value <> cell]
              all [cell value = cell fnd?: true]
            ]
          ]
        ][
          either block-data? [
            either block? value [
              until [
                i: i + 1
                any [
                  all [i = length? data value <> pick data i]
                  all [value = pick data i fnd?: true]
                ]
              ]
            ][
              until [
                i: i + 1
                any [
                  i > length? data
                  all [
                    d: pick data i
                    any [
                      not object? d
                      d: next second pick data i
                    ]
                    either wild [
                      j: 0
                      until [
                        j: j + 1
                        any [
                          all [
                            series? pick d j
                            fnd?: found? find/match pick d j value
                          ]
                          j >= length? d
                        ]
                      ] fnd?
                    ][
                      fnd?: found? find d value
                    ]
                  ]
                ]
              ]
            ]
          ][
            all [
              fnd?: found? find data value
              i: index? find data value
            ]
          ]
        ]
        either fnd? [
          set-sel-cnt i
          follow
          if act [do-action 'list-action]
          get-row
        ][
          none
        ]
      ]
    ]
    get-cell: make function! [
      cell [integer! word!] /here pos /raw rpos /local id
    ] [
      check-column cell [
        id: get-id pos rpos here raw
        if all [id not empty? data-columns not empty? data] [
          attempt [
            either object-data? [
              get in get-row/raw id cell
            ][
              pick get-row/raw id
                either word? cell [index? find data-columns cell][cell]
            ]
          ]
        ]
      ]
    ]
    get-block: make function! [/local ar r rng] [
      if all [not empty? context-list/range] [
        ar: 1 + abs subtract first context-list/range last context-list/range
        ar-blk: array/initial second ar array/initial first ar copy ""
        r: subtract first context-list/range 1
        repeat i length? context-list/range [
          rng: pick context-list/range i
          poke pick ar-blk
            subtract second rng second r
            subtract first rng first r
              pick pick data second rng first rng
        ] ar-blk
      ] copy []
    ]
    get-col: make function! [column [word!] /local c out] [
      check-column column [
        out: make list! []
        either object-data? [
          repeat d data [insert tail out get in d column]
        ][
          c: col-idx column
          repeat d data [insert tail out pick d c]
        ]
        to block! head out
      ]
    ]
    get-unique: make function! [column [word!] /local c] [
      check-column column [unique get-col column]
    ]

    ; data manipulation functions

;when starting to append empty rows, the size of the list is not known

    block-data?: make function! [] [
      ; this doesn't work correctly if the block is empty
      not all [
        not empty? data
        not found? find [block! object!] type?/word first data
      ]
    ]
    object-data?: make function! [] [
      any [
        ; this is dangerous, as it assumes that the output
        ; of the function is an object
        ; but it speeds object-data? up because the function is not evaluated
        any-function? get 'default-object
        object? default-object
        all [any-block? data not empty? data object? first data]
      ]
    ]
    unkey: make function! [vals] [
      copy/deep either all [block? vals find vals set-word!] [
        extract/index vals 2 2
      ][vals]
    ]
    by-key: make function! [vals /local out] [
      out: array length? data-columns
      foreach [word value] vals [poke out col-idx to word! word value]
      out
    ]
    col-idx: make function! [column [word!] /viewed] [
      check-column column [
        index? find either viewed [viewed-columns][data-columns] column
      ]
    ]
    sel-col-idx: make function! [] [col-idx selected-column]
;    clear: make function! [] [data: copy [] dirty?: true filter-list]
    insert-row: make function! [
      /here pos [integer!] /raw rpos [integer!] /act /values vals /keys
      /local id old-update
    ] [
      make-data
      old-update: update?
      update?: false
      id: get-id pos rpos here raw
      either empty? data [
        insert/only data either values [unkey vals][make-row]
      ][
        all [
          id insert/only at data id
            either values [
              either object-data? [
                ; changed from vals, perhaps this constitutes a copy bug in change-obj?
                make any [default-object make object! []] vals
              ][
                either keys [by-key vals][unkey vals]
              ]
            ][
              make-row
            ]
        ]
      ]
      dirty?: true
      filter-list/full
      update?: old-update
      if act [do-action 'list-action]
      if update? [show [lst scr]]
      get-row/raw id
    ]
    insert-block: make function! [pos [integer!] vals] [
      all [pos pick data pos insert at data pos vals filter-list]
    ]
    append-row: make function! [
      /values vals /keys /act /no-select /local old-update
    ] [
      make-data
      old-update: update?
      update?: false
      ; should be possible to insert values sporadically here
      either values [
        all [
          vals
          insert/only tail
            data
              either object-data? [
                vals
              ][
                either keys [by-key vals][unkey vals]
              ]
        ]
      ][
        insert/only tail data either object-data? [
          make any [default-object make object! []] []
        ][
          data make-row
        ]
      ]
      dirty?: true
      filter-list/full
      update?: old-update
      unless no-select [
        max-cnt
        if act [do-action 'list-action]
      ]
      if update? [show [lst scr]]
      get-row/raw length? data
    ]
    append-block: make function! [vals /local old-update][
      old-update: update?
      update?: false
      insert tail data vals
      dirty?: true
      filter-list/full
      update?: old-update
      last-cnt
    ]
    ; this is kind of a bad name, since we have range-diff and get-range
    range-func: make function! [/cols /old /local r] [
      r: copy either old [context-list/old-range][context-list/range]
      forall r [change r either cols [first first r][second first r]]
      unique r
    ]
    range-rows: make function! [] [range-func]
    range-columns: make function! [] [range-func/cols]
    remove-row: make function! [
      /here pos [integer!] /raw rpos [integer!] /no-select /act /local id r
    ] [
      id: get-id pos rpos here raw
      all [
        id
        pick data id
        not empty? get-range
        do [if edt/show? [hide-edit update] true]
        switch select-mode [
          single-row [remove at data id]
          multi-row [
            r: range-func
            forall r [remove at data first r]
          ]
        ]
        dirty?: true
        filter-list/full
        ; bottom clamping is not happening here
        either no-select [set-sel-cnt none true][limit-sel-cnt]
        act
        do-action 'list-action
      ]
    ]
    remove-block: make function! [pos range] [
      for i pos range 1 [remove at data pick sort-index i]
      dirty?: true
      filter-list/full
    ]
    remove-block-here: make function! [range] [
      remove-block range filter-sel-cnt
    ]
    change-row: make function! [
      vals /here pos [integer!] /raw rpos [integer!] /top /act /local id tmp
    ] [
      id: get-id pos rpos here raw
      all [
        id
        pick data id
        change/only
          at data id
          either any [not block-data? object-data?] [vals][unkey vals]
      ]
      if top [
        tmp: copy get-row/raw id
        remove-row/raw id
        insert-row/values/raw tmp 1
        first-cnt
      ]
      dirty?: true
;      filter-list/single id
      filter-list/full
      if act [do-action 'list-action]
      get-row/raw id
    ]
    change-block: make function! [pos [integer! pair!] vals [block!]] [
      either pair? pos [][
        for i sel-cnt length? vals 1 [change at data pick sort-index i]
      ]
      dirty?: true
      filter-list/full
    ]
    change-block-here: make function! [vals [block!]] [
      switch select-mode [
        single-row [change-block as-pair sel-cnt col-idx selected-column vals]
        row [change-block sel-cnt reduce [vals]]
        multi [change-block first range vals]
        multi-row [change-block first range vals]
        column [change-block first range vals]
      ]
    ]
    move-row: make function! [
      from-cnt [integer! block!] to-cnt [integer!] /local tmp old-update
    ][
      either <> from-cnt to-cnt [
        old-update: update?
        update?: false
        either block? from-cnt [
          tmp: make block! []
          repeat row from-cnt [append/only tmp get-row/raw row]
        ][
          tmp: get-row/raw from-cnt
        ]
        repeat row to-block from-cnt [
          remove-row/no-select/raw row
        ]
        ; when removing a row, cnt is inadvertently moved
        ; there is a problem adding multiple rows
;        foreach row tmp [
          insert-row/values/raw tmp to-cnt
 ;       ]
        update?: old-update
;        follow
      ][false]
    ]
    move-selected-row: make function! [to-cnt] [move-row sel-cnt to-cnt]
    move-row-up: make function! [/local tmp old-update] [
      old-update: update?
      update?: false
      tmp: get-row
      either tail-cnt? [remove-row limit-sel-cnt][remove-row prev-cnt]
      insert-row/values tmp
      update?: old-update
      follow
    ]
    move-row-down: make function! [/local tmp old-update] [
      unless tail-cnt? [
        old-update: update?
        update?: false
        next-cnt
        move-row-up
        update?: old-update
        next-cnt
      ]
    ]
    change-cell: make function! [
      col val /here pos [integer!] /raw rpos [integer!]
      /top /act /obj /local id tmp
    ] [
      ; support changing single values in objects later
      check-column col [
        id: get-id pos rpos here raw
        either select-mode = 'single-row [
          ; Change cells with SEL-CNT
          if all [id pick data id] [
            either object-data? [
              set in pick data id col val
            ][
              either obj [
                change/only
                  at pick data id col-idx col
                  make pick pick data id col-idx col val
              ][
              ; seems it won't accept empty blocks
                either object-data? [
                  set in pick data id col val
                ][
                  change/only at pick data id col-idx col val
                ]
              ]
            ]
            ; some kind of bug here. the list updates but corrupts the bottom row
            ; filter-list/single id
            filter-list/full
            if top [
              tmp: copy pick data id
              remove at data id
              set first data tmp
            ]
            if act [do-action 'list-action]
            get-row/raw id
          ]
        ][
          ; Change cells with RANGE
          ; get all rows
          ids: unique head repeat r context-list/range [
            insert [] second r ; will this work more than once?
          ]
          ; changes each single ID
          repeat id ids either object-data? [
            [change at data id make pick data id reduce [to set-word! col val]]
          ][
            [change at pick data id col-idx col val]
          ]
          filter-list/full
          if act [do-action 'list-action]
        ]
      ]
    ]
    change-cells: make function! [val] [
      ; change
    ]
    make-row: make function! [] [
      either block-data? [
        either object-data? [
          make default-object []
        ][
          array/initial length? data-columns copy ""
        ]
      ][
        copy ""
      ]
    ]
    acquire: make function! [] [
      unless empty? acquire-func [append-row/values do acquire-func]
    ]

    ; visual editing functions

    show-edit: make function! [/column col /local vals result i row] [
      if sel-cnt [
        place-edit
        old-edit: copy/deep vals: copy/deep either object? row: get-row [
          next second row
        ][
          head insert make block! 1 row
        ]
        use data-columns compose/deep [
          set bind [(viewed-columns)] 'self edt/pane
          repeat i length? viewed-columns [
            set in pick edt/pane i 'text pick vals pick indices i
            set in pick edt/pane i 'data pick vals pick indices i
            set in pick edt/pane i 'var pick viewed-columns i
          ]
          result: either all [edit-action not empty? edit-action] [
            do bind [(edit-action)] 'self
          ][
            true
          ]
        ]
        if result [
          unless selected-column [selected-column: first editable-columns]
          f-col: index? find viewed-columns selected-column
          either edt/pane/:f-col/style = 'list-field [
            ; ---------- Focus the field for the selected column
            focus pick edt/pane f-col
          ][
            ; ---------- Find the first focusable field
            i: 0
            until [
              f-col: (f-col // length? viewed-columns) + 1
              i: i + 1
              any [
                all [
                  edt/pane/:f-col/style = 'list-field
                  focus pick edt/pane f-col true
                ]
                i = length? viewed-columns
              ]
            ]
          ]
          show [lst edt]
        ]
      ]
    ]

    hide-edit: make function! [/no-submit] [
      if edt/show? [
        either no-submit [submit-edit/cancel][submit-edit]
        edt/show?: false
      ]
    ]

    submit-edit: make function! [/cancel /local changed-value vals] [
      use data-columns compose/deep [
        set [(viewed-columns)] edt/pane
        if sel-cnt [
          vals: get-row
          repeat i length? data-columns [
            if find editable-columns pick data-columns i [
              changed-value: either cancel [
                pick old-edit i
              ][
                get in get pick [(data-columns)] i 'text
              ]
              either block-data? [
                either object-data? [
                  if changed-value [
                    vals:
                      make vals
                      reduce [
                        to set-word!
                          pick data-columns i
                        changed-value
                      ]
                  ]
                ][
                  change at vals i changed-value
                ]
              ][
                poke data sel-cnt changed-value
              ]
            ]
          ]
          all [object-data? change-row vals]
          last-edit: either edt/show? [head insert tail copy [] get-row][none]
          submit-edit-func
        ]
      ]
    ]

    cursor-move: func [data [block!] /local op size move] [
      op: none
      size: 1
      parse data [
        any [
          ['left (move: 1x0 op: :subtract)] |
          ['right (move: 1x0 op: :add)] |
          ['down (move: 0x1 op: :add)] |
          ['up (move: 0x1 op: :subtract)]
        ]
        opt 'jump set size integer!
      ]
      if get 'op [
        cursor:
          min
            as-pair
              length? viewed-columns value-size
              max 1x1 op cursor multiply size move
      ]
    ]

    ; Global Feel function block for keyboard and scrollwheel navigation

    key-action-block: [
      all [get in self 'key-action do bind get in self 'key-action 'event]
    ]

    kb-feel: copy [
      if find [scroll-line scroll-page] event/type [
        face/cnt:
          max
            min
              face/value-size - face/list-size
              add
                face/cnt
                multiply
                  either console [negate event/offset/y][event/offset/y]
                  either 'scroll-page = event/type [face/list-size][1]
            0
        face/move-edit
        face/set-scr
      ]
      switch face/select-mode [
        single [
          either find [up down left right] event/key [
            face/cursor-move reduce [event/key]
          ][
            do key-action-block
          ]
        ]
        single-row [
          switch/default event/key [
            up [
              face/cursor-move [up]
              face/prev-cnt/act
            ]
            down [
              face/cursor-move [down]
              face/next-cnt/act
            ]
          ]
          key-action-block
        ]
        multi [
          switch/default event/key [
            up [
              face/cursor-move either event/shift [
                [up jump (list-size)]
              ][
                [up]
              ] 
            ]
            down [
              face/cursor-move either event/shift [
                [down jump (list-size)]
              ][
                [down]
              ]
            ]
            left [
              either event/shift [
                face/cursor/x: 1
              ][
                face/cursor-move [left]
              ]
            ]
            right [
              face/cursor-move either event/shift [
                [right jump (length? viewed-columns)]
              ][
                [right]
              ]
            ]
          ]
          key-action-block
        ]
        multi-row [
          switch/default event/key [
            ; perhaps change so that selection is possible with shift, rather than jumping screens.
            up [
              either event/shift [
                face/cursor-move [up jump (list-size)]
              ][
                face/cursor-move [up]
                face/prev-cnt/act
              ]
            ]
            down [
              either event/shift [
                face/cursor-move [down jump (list-size)]
              ][
                face/cursor-move [down]
                face/next-cnt/act
              ]
            ]
          ]
          key-action-block
        ]
        column [
          switch/default event/key [
            left [
              either event/shift [
                face/cursor/x: 1
              ][
                face/cursor-move [left]
              ]
            ]
            right [
              face/cursor-move either event/shift [
                [right jump (length? viewed-columns)]
              ][
                [right]
              ]
            ]
          ]
          key-action-block
        ]
        horizontal [
          switch/default event/key [
            up [
              face/cursor-move either event/shift [
                [up jump (list-size)]
              ][
                [up]
              ]
            ]
            down [
              face/cursor-move either event/shift [
                [down jump (list-size)]
              ][
                [down]
              ]
            ]
            left [
              either event/shift [
                face/cursor/x: 1
              ][
                face/cursor-move [left]
              ]
            ]
            right [
              face/cursor-move either event/shift [
                [right jump (length? viewed-columns)]
              ][
                [right]
              ]
            ]
          ]
          key-action-block
        ]
        vertical [
          switch/default event/key [
            up [
              face/cursor-move either event/shift [
                [up jump (list-size)]
              ][
                [up]
              ]
            ]
            down [
              face/cursor-move either event/shift [
                [down jump (list-size)]
              ][
                [down]
              ]
            ]
            left [
              either event/shift [
                face/cursor/x: 1
              ][
                face/cursor-move [left]
              ]
            ]
            right [
              face/cursor-move either event/shift [
                [right jump (length? viewed-columns)]
              ][
                [right]
              ]
            ]
          ]
          key-action-block
        ]
      ]
      show face/scr
      show face/lst
    ]

    ; initialization

    col-obj: make object! [
      width: 0
      name: copy ""
      word: none
      offset: 0
    ]

    make-data: does [if none? data [data: make block! []]]

    init-code: make function! [
      /local val no-header-columns fd
    ] [
      even-odd-colors: reduce [colors/even colors/odd]
      all [redraggable-rows allow-sort-func: false]
      unless object? context-list [context-list: make ctx-list []]
      ; does this need to be initialized every time?
      feel: make feel [
        engage: make function! [face act event] kb-feel
        redraw: make function! [face act pos] [
          if debug-redraw [print [var act now/time/precise]]
        ]
      ]
      make-data

      ; sets the names of data columns if it was not originally set
      if empty? data-columns [
        case [
          ; objects
          object-data? [
            data-columns: copy next first either none? default-object [
              ; assumes that data contains an object in the first row
              first data
            ][
              default-object
            ]
          ]
          ; blocks in blocks
          block-data? [
            ; assumes that data contains a block in the first row
            either empty? data [
              insert data-columns 'column1
            ][
              repeat i length? first data [
                insert tail data-columns
                  to word! any [
                    attempt [to string! to integer! pick first data i]
                    join 'Number i
                  ]
              ]
            ]
          ]
          ; single block
          true [
            ; TODO: do something here for fixed record size later
            insert data-columns 'column1
          ]
        ]
      ]
      if none? viewed-columns [viewed-columns: copy data-columns]

      ; ---------- Column objects
      ; ---------- derived from the block that we entered in the layout

      if no-header-columns: none? header-columns [
        header-columns: make block! length? data-columns
        repeat d data-columns [insert tail header-columns to string! d]
      ]
      if all [fit none? resize-column] [resize-column: first viewed-columns]
      if none? types [types: copy array/initial length? data-columns 'text]

      indices: make block! []
      either empty? viewed-columns [
        repeat i length? data-columns [insert tail indices i]
      ][
        repeat i viewed-columns [
          all [val: find data-columns i insert tail indices index? val]
        ]
      ]
      unless block? editable-columns [
        editable-columns: either block? readonly-columns [
          difference viewed-columns readonly-columns
        ][
          viewed-columns
        ]
      ]
      if any [
        empty? sort-direction
 ;       not-equal? length? sort-direction length? viewed-columns
        not-equal? length? sort-direction length? data-columns
        ; may want reset sort here? this will avoid a crash if the data-column names change
      ][
;        sort-direction: array/initial length? viewed-columns 'nosort
        sort-direction: array/initial length? data-columns 'nosort
      ]
      if 1 = length? viewed-columns [redraggable-columns: false]
      ; set up CTX-LIST
      
      context-list/cols: length? viewed-columns
      context-list/rows: length? data
      
      ; set panes up here
      drag-marker-face: make face [
        edge: none
        size: 0x2
        color: colors/marker
        show?: false
        old-offset: 0x0
      ]
      hdr-face: make face [
        edge: none
        size: 0x20
        pane: copy []
      ]
      hdr-fill-btn-face: make face [
        style: hdr-fill-btn
        color: colors/header-fill
        var: none
        edge: make button-edge [size: 0x1]
      ]
      hdr-btn-face: make face [
        style: 'hdr-btn
        size: 20x20
        color: colors/header-inactive
        var: none
        eff-blk: copy/deep [draw [
          pen none fill-pen white polygon 3x5 7x14 11x5] flip
        ]
        show-sort-hdr: make function! [face] [
          if all [sort-column face/var = sort-column] [
            face/effect: switch pick sort-direction col-idx sort-column [
              asc [head insert tail copy eff-blk 1x1]
              desc [head insert tail copy eff-blk 1x0]
            ][none]
          ]
        ]
        btn-style: make function! [face style [word!]] [
          face/edge/effect: style
          show face
        ]
        old-event: none
        mouse-offset: none
        header-drag: none
        left-face: none
        right-face: none
        drag-mode: false
        drag-image: list-image: none
        corner: none
        find-offset: func [size [integer!] block [block!] /local i] [
          i: 0
          until [
            i: i + 1
            any [
              none? pick block i + 1
              size <= pick block i + 1
            ]
          ] i
        ]
        do-drag: func [
          face act evt
          /local f faces old-idx new-idx item-start-pos item-index
        ] [
          f: face/parent-face/parent-face
          faces: f/viewed-columns
          if all [redraggable-columns 'alt-down <> face/old-event] [
            face/header-drag: evt/offset - face/mouse-offset
            face/drag-mode: either any [
              face/drag-mode 20 < abs face/header-drag/x
            ] [
              if all [none? face/drag-image face/drag-mode = false] [
                use [l-img column-images l i] [
                  l-img: to image! f
                  column-images: copy []
                  i: 0
                  repeat c f/viewed-columns [
                    i: i + 1
                    either c <> face/var [
                      insert tail column-images make column-face [
                        image: f/create-column-image pick f/hdr/pane i
                        size: as-pair
                          first get in pick f/hdr/pane i 'size
                          f/size/y
                        offset: as-pair
                          first get in pick f/hdr/pane i 'offset
                          0
                      ]
                    ][
                      face/drag-image: make column-face [
                        image: f/create-column-image face
                        size: as-pair
                          first get in pick f/hdr/pane i 'size
                          f/size/y
                        offset: face/offset
                        edge: make drag-edge []
                      ]
                    ]
                  ]
                  insert tail column-images face/drag-image
                  face/list-image: last head
                    insert tail f/pane
                      make column-face [
                        size: f/size - as-pair f/scroller-width 0
                        pane: column-images
                      ]
                  hide lst
                  show face/parent-face/parent-face
                ]
              ]
              face/drag-image/offset/x:
                face/offset/x + face/header-drag/x

;'items are not done

              item-start-pos: pick px-offsets item-index: f/col-idx face/var
              either face/drag-image/offset/x > item-start-pos [
                repeat i length? px-offsets [
                  all [
;                    face/drag-image/offset/x >
;                      subtract pick px-offsets i 0.5 * pick px-widths i
;                    i < item-index

;                    f/offsets/:i
;                    items/:i/offset/x:
;                      items/:i/offset/x - face/drag-image/size/x
                  ]
                ]
              ][
                repeat i length? px-offsets [
                  all [
                    face/drag-image/offset/x >
                      subtract pick px-offsets i 0.5 * pick px-widths i
                    i > item-index
                    items/:i/offset/x:
                      items/:i/offset/x - face/drag-image/size/x
                  ]
                ]
              ]
              
              either face/drag-image/offset/x > pick px-offsets f/col-idx face/var ['right]['left]
              prin old-idx: f/col-idx face/var
              prin new-idx: find-offset face/drag-image/offset/x f/px-offsets
              prin "."
              if old-idx <> new-idx [
                either old-idx > new-idx [
                  ; We are moving to the left
                  ; we need a list of offsets from px-offset that are moved a
                  ; number of pixels to the left to trigger the offset at the right time
          ;        foreach p px-offsets
                  
                ][
                  ; We are moving to the right
                  
                ]
                ; Move the column in these three blocks
                f/viewed-columns
                f/header-columns
                f/widths
                calc-px-values
              ]
              if face/parent-face/parent-face/long-enough [
                face/parent-face/parent-face/update-speed: now/time/precise
                show face/list-image
                show face/drag-image
                face/parent-face/parent-face/update-speed:
                  now/time/precise -
                    face/parent-face/parent-face/update-speed * 1.5
              ]
              true
            ][
              false
            ]
          ]
        ]
        font: make standard-header-font []
        para: make standard-header-para []
        feel: make feel [
          engage: make function! [face act evt /local i f][
            f: face/parent-face/parent-face
            if f/allow-sort-func [
              switch act [
                down [
                  either all [editable? edt/show?] [
                    pre-submit-edit-func
                    hide-edit
                    f/set-focal-face f
                    update
                  ][
                    ; performs excessive show
                    f/set-focal-face f
                  ]
                  face/old-event: 'down
                  face/edge/effect: 'ibevel
                  face/mouse-offset: evt/offset
                  show face
                ]
                alt-down [
                  face/old-event: 'alt-down
                  face/edge/effect: 'bevel
                  repeat h hdr/pane [all [h/style = 'hdr-btn h/effect: none]]
                  lst/parent-face/reset-sort
                  face/mouse-offset: evt/offset
                ]
                over [
                  if find [down away] face/old-event [btn-style face 'ibevel]
                  face/do-drag face act evt
                  if 'alt-down <> face/old-event [face/old-event: 'over]
                ]
                away [
                  btn-style face 'bevel
                  face/do-drag face act evt
                  if 'alt-down <> face/old-event [face/old-event: 'away]
                ]
                up [
                  face/edge/effect: 'bevel
                  lst/parent-face/do-action 'sort-action
                  lst/parent-face/hidden-column: none
                  if face/drag-image [
                    remove back tail f/pane
                    ;probe length? f/pane
                    face/drag-image: face/list-image: none
                    show lst
                  ]

                  ; ---------- Change Sorting

                  if all [not face/drag-mode 'away <> face/old-event] [
                    face/old-event: none
                    either face/corner [sort-column: none][
                      sort-column: face/var
                      ;i: col-idx/viewed sort-column
                      i: col-idx sort-column
                      either all [
                        sort-column old-sort-column
                        old-sort-column = sort-column
                      ] [
                        ; cycle sorting in the same column
                        change at sort-direction i either tri-state-sort [
                          sort-modes:
                            find head sort-modes pick sort-direction i
                          sort-modes: either tail? next sort-modes [
                            head sort-modes
                          ][
                            next sort-modes
                          ]
                          first sort-modes
                        ][
                          either 'asc = pick sort-direction i ['desc]['asc]
                        ]
                      ][
                        ; switching to a new column, do not cycle
                        old-sort-column: sort-column
                      ]
                      set-header-buttons
                    ]
                    list-sort
                    if filtering? [
                      sort-index: intersect sort-index filter-index
                    ]
                    if limit [sort-index: copy/part sort-index limit]
                    follow
                  ]
                  face/drag-mode: false
                  attempt [show f]
                ]
              ]
            ]
          ]
        ]
      ]
      hdr-corner-btn-face: make face [
        edge: none
        style: 'hdr-corner-btn
        size: 20x20
        color: colors/header-inactive
        effect: none
        var: none
        feel: make feel [
          engage: make function! [face act evt /local f][
            f: face/parent-face/parent-face
            if f/allow-sort-func [
              if all [editable? edt/show?] [
                hide-edit
                f/set-focal-face f
                update
              ]
              if find [down alt-down] act [
                face/edge/effect: 'ibevel
                repeat i subtract length? hdr/pane 1 [
                  set in pick hdr/pane i 'effect none
                ]
                show face
              ]
              if act = 'up [
                face/edge/effect: 'bevel
                sort-column: none
;                sort-direction: array/initial length? viewed-columns 'nosort
                sort-direction: array/initial length? data-columns 'nosort
                filter-list
                follow
                set-header-buttons
                attempt [show f]
              ]
            ]
          ]
        ]
      ]
      lst-face: make face [
        edge: none
        size: 100x100
        subface: none
        single: none
        pane-fill: none
        feel: make feel [
          over: make function! [face ovr /local f lv] [
          ]
        ]
      ]

      scr-face: make get-style 'scroller copy/deep [
        action: make function! [/local value vl] [
          if long-enough [
            vl: value-size - list-size
            value: to integer! either console [
              (1 - scr/data) * max 0 vl
            ][
              scr/data * max 0 vl
            ]
            if all [cnt <> value][
              update-speed: now/time/precise
              scr/data: switch/default cnt: value [
                0 [0]
                vl [1]
              ][scr/data]
              show [lst scr]
              move-edit
              update-speed: now/time/precise - update-speed
            ]
          ]
        ]
        feel: make feel [
          redraw: func [face act pos][
            face/data: max 0 min 1 face/data 
            if face/data <> face/state [
              pos: face/size - face/pane/1/size -
                (2 * face/edge/size) - (2 * face/clip) 
              either face/size/x > face/size/y [
                face/pane/1/offset/x: face/data * pos/x + face/clip/x
              ] [
                face/pane/1/offset/y: face/data * pos/y + face/clip/y
              ] 
              face/state: face/data 
              if act = 'draw [show face/pane/1]
            ]
          ]
          engage: func [f act evt /local tmp][
            if act = 'down [
              tmp: f/axis
              cnt: either evt/offset/:tmp > f/pane/1/offset/:tmp [
                min cnt + list-size value-size - list-size
              ][
                max 0 cnt - list-size
              ]
              set-scr
              show [lst scr]
            ]
          ]
        ]
        init: [
          pane: reduce [
            make dragger [
              edge: make edge []
              feel: make svvf/drag bind [
                engage: func [face action event] [
                  if find [over away] action [
                    drag-off
                      face/parent-face
                      face
                      face/offset + event/offset - face/data
                  ]
                  if 'up = action [
                    scrolling?: false
                    show face
                  ]
                  if find [down alt-down] action [
                    scrolling?: true
                    face/data: event/offset
                  ]
                ]
              ] svvf
            ]
            axis: make svv/vid-styles/arrow [
              edge: make edge []
              color: none
              colors: [0.0.0 0.0.0]
              action: [
                if list-size < value-size [
                  cnt: max 0 cnt - 1
                  set-scr
                  show [lst scr]
                ]
              ]
              feel: make svvf/scroll-button []
            ]
            make axis [
              edge: make edge []
              action: [
                if list-size < value-size [
                  cnt: min cnt + 1 value-size - list-size
                  set-scr
                  show [lst scr]
                ]
              ]
            ]
          ]
          if colors [
            color: first colors pane/1/color: second colors
            pane/2/colors: pane/3/colors:
              head insert tail copy at colors 2 pane/2/colors/2
          ]
          axis: pick [y x] size/y >= size/x
          resize size
        ]
      ]
      do bind scr-face/init in scr-face 'init

      hscr-face: make-face get-style 'scroller
      use [sp hp] [
        sp: scr-face/pane
        hp: hscr-face/pane
        sp/1/color: sp/2/colors/1: sp/3/colors/1:
        hp/1/color: hp/2/colors/1: hp/3/colors/1: colors/header-inactive
        sp/2/colors/2: sp/3/colors/2: hp/2/colors/2: hp/3/colors/2:
          colors/glyph
        sp/1/edge/color: sp/2/edge/color: sp/3/edge/color:
        hp/1/edge/color: hp/2/edge/color: hp/3/edge/color: colors/list-edge
      ]

      edt-face: make face [
        edge: pane: none
        font: make standard-font []
        text: ""
        show?: false
      ]
      drg-face: make face [
        edge: make edge [size: 1x1 color: black]
        feel: pane: color: none
        text: ""
        effect: [merge]
        show?: false
      ]
      page-scr-face: make-face get-style 'double-arrow
      page-scr-face/colors: reduce [colors/header-inactive colors/glyph]
      page-scr-face/edge/color: colors/list-edge
      pane: reduce [
        make hdr-face []
        make lst-face []
        make scr-face []
        make edt-face []
        make hscr-face []
        make drag-marker-face []
        make drg-face []
        make page-scr-face [
          data: 'up
          action: make function! [face value] [
       ;     probe 'up
       ;     probe face/parent-face/data
            face/parent-face/prev-page-cnt
            face/parent-face/update
          ]
        ]
        make page-scr-face [
          data: 'down
          action: make function! [face value] [
         ;   probe 'down
            face/parent-face/next-page-cnt
            update
          ]
        ]
      ]

      set [hdr lst scr edt hscr drgm drg pup pdn] pane

      ; initialize widths, cols and fonts

      if any [
        none? px-widths
        old-widths <> widths
        old-size <> size
        old-viewed-columns <> viewed-columns
      ] [
        if any [
          none? widths
          all [old-viewed-columns old-viewed-columns <> viewed-columns]
        ] [
          widths: array/initial
            length? viewed-columns to decimal! 1 / length? viewed-columns
        ]
        if any [
          none? fonts
          all [old-fonts old-fonts <> fonts]
        ] [
          fonts: array/initial length? viewed-columns make standard-font []
        ]
        if any [
          none? paras
          all [old-paras old-paras <> paras]
        ] [
          paras: array/initial length? viewed-columns make standard-para []
        ]
        old-viewed-columns: copy viewed-columns
        old-widths: copy widths
      ]

      ; ---------- Element sizes are set up here

      edged-size: size - (2 * edge/size)
      hdr/size/x: edged-size/x
      scr/resize/x scroller-width
      pup/size: pdn/size: either page-scroll [
        as-pair scroller-width scroller-width
      ][
        0x0
      ]
      calc-px-values
      lst/size: as-pair
        edged-size/x - scroller-width
        edged-size/y - add
          either h-scroll [scroller-width][0]
          lst/offset/y: either empty? header-columns [0][hdr/size/y]
      if empty? header-columns [hdr/size/y: 0]
      drgm/size/x: lst/size/x

      unless empty? viewed-columns [lst-lo]

      scr/resize/y lst/size/y - either page-scroll [
        pup/size/y + pdn/size/y
      ][
        0
      ]
      either h-scroll [
        hscr/offset/y: lst/size/y + lst/offset/y
        hscr/axis: 'x
        hscr/resize as-pair lst/size/x either h-scroll [scroller-width][0]
        hscr/redrag divide (size/x - scroller-width) col-widths
;        hscr/redrag lst/size/x / (size/x - scroller-width)
      ][
        hscr/size: 0x0
      ]
      scr/offset:
        as-pair
          lst/size/x
          lst/offset/y + either page-scroll [pup/size/y][0]
      if page-scroll [
        pup/offset: as-pair lst/size/x lst/offset/y
        pdn/offset:
          as-pair pup/offset/x lst/size/y + lst/offset/y - scroller-width
      ]

      ; list initialization (not much going on here)

      hscr/action: make function! [/local value] [
        scrolling?: true
        value: do replace/all trim/with mold px-widths "[]" " " " + "
        hdr/offset/x: lst/offset/x: negate (value - lst/size/x) * hscr/data
        show self
      ]
      
      ; drag'n'drop fields initialization

      drg/pane: get in layout/tight
        ; ---------- This is unfinished!
;       either row-face [
;        use [pos drg-face i j] [
;          drg-face: copy row-face
;          i: j: 0
;          pos: drg-face
;          until [
;            i: i + 1
;            pos: find pos 'list-text
;            j: j + 1
;            change pos 'list-field
;            if j = length? editable-columns [
;              insert/only next pos
;            ]
;            
;            either vc: find editable-columns pick viewed-columns i [
;            ][
;              insert pos: next pos [feel none]
;            ]
;            any [
;              none? pos
;              tail? pos
;              i = length? viewed-columns
;            ]
;          ] drg-face
;        ]
;      ][
        use [drg-lo] [
          drg-lo: copy [across space 0]
          repeat i length? viewed-columns [
            insert tail drg-lo 'list-text-box
            insert tail drg-lo lst/subface/pane/:i/size/x
            insert tail drg-lo yellow
          ] drg-lo
        ]
      ;]
       'pane

      if redraggable-rows [
        repeat e drg/pane [
          e/color: 255.0.0.128
;e/effect: [merge]
;e/text: "test"
          either row-face [
            e/font: make standard-font [
              size: e/font/size
              style: e/font/style
              align: e/font/align
            ]
            e/para: make standard-para [
              origin: 0x0
              margin: 0x0
              indent: e/para/indent
            ]
          ][
            e/font: make standard-font []
          ]
        ]
        drg/size: lst/subface/size
      ]
      
      ; edit fields initialization

      edt/pane: get in layout/tight either row-face [
        use [pos edt-face i j vc] [
          edt-face: copy row-face
          i: j: 0
          pos: edt-face
          until [
            i: i + 1
            pos: find pos 'list-text
            either vc: find editable-columns pick viewed-columns i [
              j: j + 1
              change pos 'list-field
              if j = length? editable-columns [
                insert/only next pos 
                  either all [tab-edit-action not empty? tab-edit-action] [
                    []
                  ][
                    [
                      hide-edit
                      all [
                        <> system/view/focal-face face/parent-face/parent-face
                        focus/no-show face/parent-face/parent-face
                      ]
                      refresh
                    ]
                  ]
              ]
            ][
              insert pos: next pos [feel none]
            ]
            any [
              none? pos
              tail? pos
              i = length? viewed-columns
            ]
          ] edt-face
        ]
      ][
        use [edt-lo found-columns j] [
          edt-lo: copy [across space 0]
          repeat i length? viewed-columns [
            either j: find editable-columns pick viewed-columns i [
              insert
                insert tail
                  edt-lo
                  'list-field
                lst/subface/pane/:i/size - either i = length? viewed-columns [1x1][0x1]
            ][
              insert insert tail edt-lo 'list-text-box lst/subface/pane/:i/size/x
            ]
            insert insert tail edt-lo 'pad spacing/x
          ] edt-lo
        ]
      ] 'pane
      repeat e edt/pane [
        e/color: colors/edit-field
;        set 'yy e
;        set 'aa row-face
;        probe index? find edt/pane e
;        probe e/font
        either row-face [
          ; set font setting for each face in the row-face, because
          ; the font object is originally shared between the faces.
          e/font: make standard-font [
            ;size: any [all [e/font e/font/size] standard-font/size]
            ;style: any [all [e/font e/font/style] standard-font/style]
            ;align: any [all [e/font e/font/align] standard-font/align]
            size: e/font/size
            style: e/font/style
            align: e/font/align
          ]
          e/para: make standard-para [
            origin: 0x0
            margin: 0x0
            indent: e/para/indent
          ]
        ][
          e/font: make standard-font []
        ]
      ]
      edt/size: lst/subface/size

      filter-list
      cell?: []
      row?: []

      lst/color: select colors either fill [
        either even? list-size ['odd]['even]
      ][
        'background
      ]

      ; supply list with data

      lst/single: none
      lst/pane-fill: make function! [
        face index
        /local bd od c-index j k s gcol hcol n t sp range-cell sort-c-index
          sort-c-index+1 sort-c-index-1
      ][
;      col: either col: find viewed-columns selected-column [index? col][none]
        bd: block-data?
        od: object-data?
        hcol: if all [
          hidden-column hcol: find viewed-columns hidden-column
        ][
          index? hcol
        ]
        either integer? index [
          sort-c-index: pick sort-index c-index: + index cnt
          sort-c-index-1: pick sort-index c-index - 1
          sort-c-index+1: pick sort-index c-index + 1
          row-color: pick even-odd-colors c-index // 2 + 1
          range-cell: copy any [context-list/range []]
          s: lst/subface
          if all [index <= list-size any [fill sort-c-index]] [
            k: 0
            group-row-type: if group-rows-by [
              unless od [gcol: col-idx group-rows-by]
              row-1: all [
                sort-c-index-1
                c: pick data sort-c-index-1
                either od [get in c group-rows-by][pick c gcol]
              ]
              row-0: all [
                sort-c-index
                c: pick data sort-c-index
                either od [get in c group-rows-by][pick c gcol]
              ]
              row+1: all [
                sort-c-index+1
                c: pick data sort-c-index+1
                either od [get in c group-rows-by][pick c gcol]
              ]
              case [
                all [row-1 <> row-0 row-0 <> row+1] ['single]
                all [row-1 <> row-0 row-0 = row+1]  ['start]
                all [row-1 = row-0 row-0 = row+1]   ['between]
                all [row-1 = row-0 row-0 <> row+1]  ['end]
              ]
            ]
            repeat i length? lst/subface/pane [
              sp: either = i length? lst/subface/pane [0][first spacing]
              cell: j: pick s/pane i
              column: pick viewed-columns i
              unless scrolling? [
                unless row-face [j/offset/x: pick px-offsets i]
                all [
                  not row-face resize-column = pick data-columns i
                  j/size/x: subtract pick px-widths i sp
                ]
              ]
              ; ---------- Face Coloring
              j/color: either all [
                sort-c-index
                not empty? range-cell
                find range-cell as-pair i sort-c-index
              ] [
                either = i hcol [row-color][select-color]
              ][
                row-color
              ]
              if any [
                = i hcol
                all [not row-face h-fill > 0 i = length? lst/subface/pane]
              ] [
                j/color: * j/color 0.9
              ]
              ; ---------- Face Text
              if flag-face? j 'text [
                k: + k 1
                row: j/data: sort-c-index
                j/row: index
                either all [
                  <> i hcol
                  data
                  sort-c-index
                  pick indices k
                ] [
                  j/text: j/full-text: do either bd [
                  ; this line is hard to debug!
                    either od [
                      [pick next second pick data sort-c-index pick indices k]
                    ][
                      [pick pick data sort-c-index pick indices k]
                    ]
                  ][
                    [pick data sort-c-index]
                  ]
                  either image? j/text [
                    j/effect: compose/deep [
                      draw [
                        translate (j/size - j/text/size / 2)
                        image (j/text)
                      ]
                    ]
                    j/text: none
                    row-height
                  ][
                    j/effect: none
                    either all [
                      truncate
                      j/text
                      series? j/text
                      not empty? j/text
                      j/text: form j/text
                      (t: index? offset-to-caret j divide j/size 1x2) <= 
                        length? to string! j/text
                    ] [
                      either j/para/wrap? [
                        row-height: either variable-height [
                          second size-text j
                        ][
                          row-height
                        ]
                      ][
                        j/truncated?: true
                        j/text: join copy/part to string! j/text
                          either n: find j/text newline [
                            subtract index? n 1
                          ][
                            t - 4
                          ] "..."
                      ]
                    ][
                      j/truncated?: false
                    ]
                  ]
                  ; ---------- Row Action
                  use data-columns compose/deep [
                    if all [
                      row-action block? row-action not empty? row-action
                    ] [
                      either od [
                        do bind [(row-action)] pick data sort-c-index
                      ][
                        set
                          either bd [[(data-columns)]][[(first data-columns)]]
                          pick data sort-c-index
                        do [(row-action)]
                      ]
                    ]
                  ]
                ][j/text: j/full-text: j/effect: none]
              ]
              ; this needs to be done as an additive offset instead
              ;s/offset/y: vo-set: vo-set +
              ;  (row-height - spacing/y) * either zero? index - 1 [0][1]
              s/offset/y: either console [
                - second lst/size/y (index * s/size/y - second spacing)
              ][
                subtract index - 1 * second s/size second spacing
              ]
            ]
            s/size/y:
              + + row-height second spacing either = index list-size [
                second spacing
              ][
                0
              ]
            if = index list-size [recycle]
            s
          ]
        ][+ to integer! divide second index second lst/subface/size 1]
      ]

      lst/pane: make function! [face index] [
        either lst/single [
          either index > 1 [
            lst/single: none
          ][
            lst/pane-fill face lst/single
          ]
        ][
          if all [debug index = list-size] [
            print ["filling list:" var now/time/precise]
          ]
          lst/pane-fill face index
        ]
      ]

      ; header initialization
      unless empty? header-columns [
        o-size: 0
        repeat i min length? header-columns length? viewed-columns [
          insert tail hdr/pane make hdr-btn-face [
            corner: none
            ; this should work, but it doesn't.
;            para: standard-header-para [margin: 40x0]
            edge: make button-edge []
            offset: as-pair pick px-offsets i 0
            ; why did we need to set as word here first and then as string?
            text: pick header-columns
              either all [no-header-columns not empty? indices] [
                pick indices i
              ][
                i
              ]
            var: either all [sort-column 1 = length? viewed-columns] [
              sort-column
            ][
              pick viewed-columns i
            ]
            size:
              as-pair
              ; test this code simplification. not guaranteed to be stable.
                o-size: either all [1 = length? header-columns any [fit not h-scroll]] [
                  lst/size/x
                ][
                  pick px-widths i
                ]
                hdr/size/y
            related: 'hdr-btns
          ]
        ]
        if h-fill > 0 [
          insert tail hdr/pane make hdr-fill-btn-face [
            size: as-pair h-fill hdr/size/y
            offset: as-pair first back back tail px-offsets 0
          ]
        ]
        insert tail hdr/pane make hdr-corner-btn-face [
          offset: as-pair last px-offsets 0
          color: colors/header-inactive
          edge: make button-edge []
          size: as-pair scr/size/x hdr/size/y
        ]
        hdr/pane: reduce hdr/pane
        hdr/size/x: size/x
        repeat h hdr/pane [all [h/style = 'hdr-btn h/show-sort-hdr h]]
      ]
      set-header-buttons

      ; ---------- Position CNT correctly

      if all [value-size > list-size cnt > subtract value-size list-size] [
        cnt: - value-size list-size
      ]
    ]
    init: [init-code]
    refresh: make function! [/force /local result] [
      scrolling?: false
      either force [init-code][
        either <> size old-size [init-code][filter-list set-header-buttons]
      ]
;      limit-sel-cnt ; should be removed/optimized
      result: all [update? self/parent-face show? do [show self true]]
      do-action/no-select 'refresh-action
;      recycle ; only for testing currently. this may slow down list-view a lot.
      result
    ]
    update: make function! [/force /local old-update result] [
      old-update: update?
      update?: true
      result: either force [refresh/force][refresh]
      update?: old-update
      result
    ]
  ]
]
