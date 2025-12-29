/**
 * SPI.H - Librería SPI Master para 6502 compatible con cc65
 * 
 * Mapa de memoria SPI (Wrapper con CS manual):
 *   $C040 - RX_DATA   Dato recibido (read only)
 *   $C041 - TX_DATA   Dato a transmitir (write inicia TX)
 *   $C042 - STATUS    Estado: RRDY(6), TRDY(5), TMT(4)
 *   $C043 - CTRL      Control (interrupts IP)
 *   $C044 - SS_MASK   Máscara Slave Select (LOCAL)
 *   $C045 - CS_EN     CS Enable: bit0=1 activa CS (LOCAL)
 *
 * Chip Selects disponibles:
 *   CS[0]: SD Card (pin 38)
 *   CS[1]: Externo (pin 25)
 *   CS[2]: Externo (pin 26)
 *   CS[3]: Externo (pin 27)
 */

#ifndef SPI_H
#define SPI_H

#include <stdint.h>

/* ============================================================================
 * REGISTROS DE HARDWARE
 * ============================================================================ */

#define SPI_BASE        0xC040

#define SPI_RX_DATA     (*(volatile uint8_t *)(SPI_BASE + 0x00))
#define SPI_TX_DATA     (*(volatile uint8_t *)(SPI_BASE + 0x01))
#define SPI_STATUS      (*(volatile uint8_t *)(SPI_BASE + 0x02))
#define SPI_CTRL        (*(volatile uint8_t *)(SPI_BASE + 0x03))
#define SPI_SS_MASK     (*(volatile uint8_t *)(SPI_BASE + 0x04))
#define SPI_CS_EN       (*(volatile uint8_t *)(SPI_BASE + 0x05))

/* ============================================================================
 * BITS DE ESTADO
 * ============================================================================ */

/* Status register bits (Gowin SPI IP) */
#define SPI_STAT_TMT    0x10    /* Bit 4: TX Empty */
#define SPI_STAT_TRDY   0x20    /* Bit 5: TX Ready */
#define SPI_STAT_RRDY   0x40    /* Bit 6: RX Ready */

/* Chip Select masks */
#define SPI_CS_SD       0x01    /* CS[0]: SD Card */
#define SPI_CS_EXT1     0x02    /* CS[1]: Externo pin 25 */
#define SPI_CS_EXT2     0x04    /* CS[2]: Externo pin 26 */
#define SPI_CS_EXT3     0x08    /* CS[3]: Externo pin 27 */

/* ============================================================================
 * FUNCIONES PRINCIPALES
 * ============================================================================ */

/**
 * Inicializa el módulo SPI (llamar una vez al inicio)
 */
void spi_init(void);

/**
 * Selecciona un dispositivo SPI (activa CS)
 * @param cs_mask Máscara del chip select (SPI_CS_SD, SPI_CS_EXT1, etc.)
 * @note Permite seleccionar múltiples dispositivos con OR de máscaras
 */
void spi_select(uint8_t cs_mask);

/**
 * Deselecciona todos los dispositivos (desactiva CS)
 */
void spi_deselect(void);

/**
 * Transfiere un byte (envía y recibe simultáneamente)
 * @param data Byte a enviar
 * @return Byte recibido
 * @note Función principal - spi_send/spi_receive son wrappers de esta
 */
uint8_t spi_transfer(uint8_t data);

/* ============================================================================
 * FUNCIONES DE CONVENIENCIA
 * ============================================================================ */

/**
 * Envía un byte (equivale a spi_transfer ignorando respuesta)
 * @param data Byte a enviar
 */
void spi_send(uint8_t data);

/**
 * Recibe un byte (equivale a spi_transfer(0xFF))
 * @return Byte recibido
 */
uint8_t spi_receive(void);

/**
 * Verifica si el SPI está ocupado
 * @return 1 si ocupado, 0 si listo
 */
uint8_t spi_busy(void);

#endif /* SPI_H */
