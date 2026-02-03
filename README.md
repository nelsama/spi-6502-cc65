# spi-6502-cc65

Driver SPI Master en assembler para sistemas 6502 con cc65.

## Características

- 100% Assembler optimizado (~114 bytes)
- Soporta 4 Chip Selects independientes
- Compatible con cc65
- Modo Master, CPOL=0, CPHA=0

## Instalación

Clonar el repositorio en tu directorio de librerías:

```bash
git clone https://github.com/nelsama/spi-6502-cc65.git libs/spi-6502-cc65
```

## Hardware

Mapa de registros (configurable en `spi.s`):

| Registro | Dirección | R/W | Descripción |
|----------|-----------|-----|-------------|
| RX_DATA  | $C040 | R | Dato recibido |
| TX_DATA  | $C041 | W | Dato a transmitir |
| STATUS   | $C042 | R | RRDY(6), TRDY(5), TMT(4) |
| CTRL     | $C043 | W | Control |
| SS_MASK  | $C044 | W | Máscara Slave Select |
| CS_EN    | $C045 | W | CS Enable |

## Chip Selects

```c
#define SPI_CS_SD    0x01    // CS[0]: SD Card
#define SPI_CS_EXT1  0x02    // CS[1]: Dispositivo externo 1
#define SPI_CS_EXT2  0x04    // CS[2]: Dispositivo externo 2
#define SPI_CS_EXT3  0x08    // CS[3]: Dispositivo externo 3
```

## API

```c
#include "spi.h"

void spi_init(void);                    // Inicializar SPI
void spi_select(uint8_t cs_mask);       // Activar chip select
void spi_deselect(void);                // Desactivar CS
uint8_t spi_transfer(uint8_t data);     // Enviar/recibir byte
void spi_send(uint8_t data);            // Enviar (ignora respuesta)
uint8_t spi_receive(void);              // Recibir (envía 0xFF)
uint8_t spi_busy(void);                 // Verificar si ocupado
```

## Ejemplo

```c
#include "spi.h"

int main(void) {
    uint8_t data;
    
    spi_init();
    
    spi_select(SPI_CS_EXT1);
    data = spi_transfer(0x9F);    // Enviar comando, recibir respuesta
    spi_deselect();
    
    return 0;
}
```

## Integración con Makefile

```makefile
SPI_DIR = libs/spi-6502-cc65
INCLUDES += -I$(SPI_DIR)

$(BUILD_DIR)/spi.o: $(SPI_DIR)/spi.s
	$(CA65) -t none -o $@ $<
```

## Archivos

| Archivo | Descripción |
|---------|-------------|
| `spi.h` | Header con API y definiciones |
| `spi.s` | Implementación en assembler |
| `examples/` | Ejemplos de uso |

## 💖 Apóyame

Si disfrutas de este proyecto, considera apoyarme:

[![Support me on Ko-fi](https://img.shields.io/badge/Ko--fi-Apóyame-FF5E5B?logo=kofi&logoColor=white&style=for-the-badge)](https://ko-fi.com/nelsonfigueroa2k)

## Licencia

MIT License - ver [LICENSE](LICENSE)
