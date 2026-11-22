### Tile Pattern Table 

* 3 Areas (top, middle, bottom)
* Each area holds 256 tiles

| Screen Area | Character Rows | VRAM Range | Size |
| :--- | :--- | :--- | :--- |
| Top third (Bank 0) | 0 – 7 | `$0000` – `$07FF` | 2,048 bytes (`$0800`) |
| Middle third (Bank 1) | 8 – 15 | `$0800` – `$0FFF` | 2,048 bytes (`$0800`) |
| Bottom third (Bank 2) | 16 – 23 | `$1000` – `$17FF` | 2,048 bytes (`$0800`) |

### Tile Color Table

The Color Table at $2000–$37FF mirrors this exact 3-bank layout—also 2,048 bytes per third, with 1 byte defining the foreground/background colors for each 8-pixel row of a tile.)

