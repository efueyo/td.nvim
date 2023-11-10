# td.nvim a Tower Defense game for Neovim

`td.nvim` is a tower defense game for [Neovim][neovim].
A great plugin to procrastinate without ever leaving your terminal.

## Introduction

- You own a Tower represented by `T` in the center of your board.
- Different creeps will spawn as time moves on and they will move
  towards your tower in order to attack it.
- Your goal is to prevent your tower from running out of health points (HP ❤️). In order
  to do so you must buy upgrades.
- When you upgrade your tower, it gets more HP. Also you get more weapons to defend
  from the creeps.
- When you upgrade your weapons they become more powerful and deal more damage (⚔️).
- Some weapons have special powers like splash damage or the ability to slow down enemies.
- Each upgrade becomes more expensive.
- You earn money by killing the creeps.

## Installation

Install td.nvim like any other plugin
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'efueyo/td.nvim'
}
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- init.lua:
    {
    'efueyo/td.nvim',
    }

-- plugins/td.lua:
return {
    'efueyo/td.nvim',
    }
```

## Usage

Use the following commands or keymaps to interact with the Game

| Command          | Keymap             | Description                    |
| ---------------- | ------------------ | ------------------------------ |
| `:TDStart`       | `N/A`              | Starts the game.               |
| `:TDToggle`      | `<leader><leader>` | Toggles the game (Start/Stop). |
| `:TDStop`        | `N/A`              | Stops the game.                |
| `:UpgradeTower`  | `<leader>t`        | Upgrades the Tower.            |
| `:UpgradeGun`    | `<leader>g`        | Upgrades the Gun weapon.       |
| `:UpgradeCannon` | `<leader>c`        | Upgrades the Cannon weapon.    |
| `:UpgradeIce`    | `<leader>i`        | Upgrades the Ice weapon.       |
| `:UpgradeMine`   | `<leader>m`        | Upgrades the Mine weapon.      |

[neovim]: https://neovim.io/
