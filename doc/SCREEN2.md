### Tile Pattern Table 

* 3 Areas (top, middle, bottom)
* Each area holds 256 tiles

| Screen Area | Character Rows | VRAM Range | Size |
| :--- | :--- | :--- | :--- |
| Top third (Bank 0) | 0 – 7 | `$0000` – `$07FF` | 2,048 bytes (`$0800`) |
| Middle third (Bank 1) | 8 – 15 | `$0800` – `$0FFF` | 2,048 bytes (`$0800`) |
| Bottom third (Bank 2) | 16 – 23 | `$1000` – `$17FF` | 2,048 bytes (`$0800`) |


### Tile Name Table


| Screen Area | Rows | Name Table Range | Pattern Bank Used Automatically |
| :--- | :--- | :--- | :--- |
| Top third | 0 – 7 | `$1800` – `$18FF` | Bank 0 (`$0000`) |
| Middle third | 8 – 15 | `$1900` – `$19FF` | Bank 1 (`$0800`) |
| Bottom third | 16 – 23 | `$1A00` – `$1AFF` | Bank 2 (`$1000`) |


### Tile Color Table

The Color Table at $2000–$37FF mirrors this exact 3-bank layout—also 2,048 bytes per third, with 1 byte defining the foreground/background colors for each 8-pixel row of a tile.
)

