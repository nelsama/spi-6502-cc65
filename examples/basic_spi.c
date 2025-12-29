/**
 * Ejemplo básico de uso de la librería SPI
 * Comunicación con un dispositivo genérico
 */

#include <stdint.h>
#include "spi.h"

/* Ejemplo: leer ID de un dispositivo SPI */
uint8_t read_device_id(void) {
    uint8_t id;
    
    spi_select(SPI_CS_EXT1);    /* Seleccionar dispositivo en CS[1] */
    spi_transfer(0x9F);          /* Comando READ_ID típico */
    id = spi_transfer(0xFF);     /* Leer respuesta */
    spi_deselect();
    
    return id;
}

/* Ejemplo: enviar comando y datos */
void send_command(uint8_t cmd, uint8_t data) {
    spi_select(SPI_CS_EXT1);
    spi_transfer(cmd);
    spi_transfer(data);
    spi_deselect();
}

int main(void) {
    uint8_t id;
    
    /* Inicializar SPI */
    spi_init();
    
    /* Leer ID del dispositivo */
    id = read_device_id();
    
    /* Enviar un comando */
    send_command(0x01, 0x55);
    
    while (1);
    return 0;
}
