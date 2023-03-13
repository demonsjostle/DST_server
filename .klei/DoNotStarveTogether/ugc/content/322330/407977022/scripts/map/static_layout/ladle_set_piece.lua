return {
  version = "1.1",
  luaversion = "5.1",
  tiledversion = "0.11.0",
  orientation = "orthogonal",
  width = 8,
  height = 8,
  tilewidth = 16,
  tileheight = 16,
  nextobjectid = 2,
  properties = {},
  tilesets = {
    {
      name = "Tiles",
      firstgid = 1,
      filename = "tiles.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "tiles.png",
      imagewidth = 512,
      imageheight = 384,
      tileoffset = {
        x = 0,
        y = 0
      },
      properties = {},
      terrains = {
        {
          name = "impassible",
          tile = -1,
          properties = {}
        },
        {
          name = "cobblestone",
          tile = -1,
          properties = {}
        },
        {
          name = "rock",
          tile = -1,
          properties = {}
        },
        {
          name = "dirt",
          tile = -1,
          properties = {}
        },
        {
          name = "savannah",
          tile = -1,
          properties = {}
        },
        {
          name = "grassy",
          tile = -1,
          properties = {}
        },
        {
          name = "forest",
          tile = -1,
          properties = {}
        },
        {
          name = "marsh",
          tile = -1,
          properties = {}
        },
        {
          name = "wooden flooring",
          tile = -1,
          properties = {}
        },
        {
          name = "carpet",
          tile = -1,
          properties = {}
        },
        {
          name = "checkerboard",
          tile = -1,
          properties = {}
        }
      },
      tiles = {
        {
          id = 0,
          terrain = { 0, 0, 0, 0 }
        },
        {
          id = 1,
          terrain = { 1, 1, 1, 1 }
        },
        {
          id = 2,
          terrain = { 2, 2, 2, 2 }
        },
        {
          id = 3,
          terrain = { 3, 3, 3, 3 }
        },
        {
          id = 4,
          terrain = { 4, 4, 4, 4 }
        },
        {
          id = 5,
          terrain = { 5, 5, 5, 5 }
        },
        {
          id = 6,
          terrain = { 6, 6, 6, 6 }
        },
        {
          id = 7,
          terrain = { 7, 7, 7, 7 }
        },
        {
          id = 8,
          terrain = { 8, 8, 8, 8 }
        },
        {
          id = 9,
          terrain = { 9, 9, 9, 9 }
        },
        {
          id = 10,
          terrain = { 10, 10, 10, 10 }
        }
      }
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 8,
      height = 8,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        9, 0, 0, 0, 9, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        9, 0, 0, 0, 9, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          id = 1,
          name = "",
          type = "ladle",
          shape = "rectangle",
          x = 64,
          y = 64,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
