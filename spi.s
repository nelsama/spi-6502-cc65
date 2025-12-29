;
; SPI.S - Librería SPI Master optimizada para 6502
; Compatible con cc65 - Tang Nano 9K
;
; Mapa de memoria SPI (Wrapper con CS manual):
;   $C040 - RX_DATA   Dato recibido (read only)
;   $C041 - TX_DATA   Dato a transmitir (write inicia TX)
;   $C042 - STATUS    Estado: RRDY(6), TRDY(5), TMT(4)
;   $C043 - CTRL      Control (interrupts IP)
;   $C044 - SS_MASK   Máscara Slave Select (LOCAL)
;   $C045 - CS_EN     CS Enable: bit0=1 activa CS (LOCAL)
;

    .setcpu     "6502"
    .smart      on
    .autoimport on
    .case       on

    .export     _spi_init
    .export     _spi_select
    .export     _spi_deselect
    .export     _spi_transfer
    .export     _spi_send
    .export     _spi_receive
    .export     _spi_busy

; ---------------------------------------------------------------
; Constantes de hardware - Nuevo mapa wrapper
; ---------------------------------------------------------------
SPI_RX_DATA     = $C040     ; RX Data (read only)
SPI_TX_DATA     = $C041     ; TX Data (write starts transfer)
SPI_STATUS      = $C042     ; Status register
SPI_CTRL        = $C043     ; Control (IP interrupts)
SPI_SS_MASK     = $C044     ; Slave Select mask (LOCAL)
SPI_CS_EN       = $C045     ; CS Enable (LOCAL)

; Status bits (Gowin SPI IP)
SPI_STAT_TMT    = $10       ; Bit 4: TX Empty
SPI_STAT_TRDY   = $20       ; Bit 5: TX Ready
SPI_STAT_RRDY   = $40       ; Bit 6: RX Ready

.segment    "CODE"

; ---------------------------------------------------------------
; void spi_init(void)
; Inicializa el módulo SPI
; ---------------------------------------------------------------
.proc _spi_init
    lda     #$00
    sta     SPI_SS_MASK     ; Limpiar máscara CS
    sta     SPI_CS_EN       ; CS desactivado
    rts
.endproc

; ---------------------------------------------------------------
; void spi_select(uint8_t cs_mask)
; Selecciona un chip (activa CS)
; Entrada: A = máscara CS (bit0=SD, bit1=ext1, etc)
; ---------------------------------------------------------------
.proc _spi_select
    sta     SPI_SS_MASK     ; Guardar máscara
    lda     #$01
    sta     SPI_CS_EN       ; Activar CS
    rts
.endproc

; ---------------------------------------------------------------
; void spi_deselect(void)
; Deselecciona todos los chips
; ---------------------------------------------------------------
.proc _spi_deselect
    lda     #$00
    sta     SPI_CS_EN       ; Desactivar CS
    rts
.endproc

; ---------------------------------------------------------------
; uint8_t spi_transfer(uint8_t data)
; Transfiere un byte (envía y recibe)
; Entrada: A = byte a enviar
; Salida: A = byte recibido
; ---------------------------------------------------------------
.proc _spi_transfer
    pha                     ; Guardar dato a enviar
@wait_tx:
    lda     SPI_STATUS
    and     #SPI_STAT_TRDY
    beq     @wait_tx        ; Esperar TRDY=1
    
    pla                     ; Recuperar dato
    sta     SPI_TX_DATA     ; Enviar (inicia transferencia)
    
@wait_rx:
    lda     SPI_STATUS
    and     #SPI_STAT_RRDY
    beq     @wait_rx        ; Esperar RRDY=1
    
    lda     SPI_RX_DATA     ; Leer dato recibido
    ldx     #$00            ; cc65: resultado en A:X
    rts
.endproc

; ---------------------------------------------------------------
; void spi_send(uint8_t data)
; Envía un byte (ignora respuesta)
; Entrada: A = byte a enviar
; ---------------------------------------------------------------
.proc _spi_send
    pha                     ; Guardar dato
@wait_tx:
    lda     SPI_STATUS
    and     #SPI_STAT_TRDY
    beq     @wait_tx        ; Esperar TRDY=1
    
    pla
    sta     SPI_TX_DATA     ; Enviar
    
@wait_done:
    lda     SPI_STATUS
    and     #SPI_STAT_RRDY
    beq     @wait_done      ; Esperar que termine
    
    lda     SPI_RX_DATA     ; Leer y descartar
    rts
.endproc

; ---------------------------------------------------------------
; uint8_t spi_receive(void)
; Recibe un byte (envía 0xFF)
; Salida: A = byte recibido
; ---------------------------------------------------------------
.proc _spi_receive
@wait_tx:
    lda     SPI_STATUS
    and     #SPI_STAT_TRDY
    beq     @wait_tx        ; Esperar TRDY=1
    
    lda     #$FF
    sta     SPI_TX_DATA     ; Enviar 0xFF (dummy)
    
@wait_rx:
    lda     SPI_STATUS
    and     #SPI_STAT_RRDY
    beq     @wait_rx        ; Esperar RRDY=1
    
    lda     SPI_RX_DATA     ; Leer dato recibido
    ldx     #$00            ; cc65: resultado en A:X
    rts
.endproc

; ---------------------------------------------------------------
; uint8_t spi_busy(void)
; Verifica si SPI está ocupado (TRDY=0 significa ocupado)
; Salida: A = 1 si ocupado, 0 si listo
; ---------------------------------------------------------------
.proc _spi_busy
    lda     SPI_STATUS
    and     #SPI_STAT_TRDY
    beq     @busy           ; TRDY=0 -> ocupado
    lda     #$00            ; Listo
    ldx     #$00
    rts
@busy:
    lda     #$01            ; Ocupado
    ldx     #$00
    rts
.endproc
