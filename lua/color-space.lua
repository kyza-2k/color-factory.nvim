local default_configuration = {
  options = {
    default_highlights = true,
  },
}

return {
  colors = require('color-space.colors'),

  setup = function(configuration)
    configuration = configuration or default_configuration

    return configuration
  end,
}
