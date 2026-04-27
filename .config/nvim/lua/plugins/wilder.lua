local wilder = require('wilder')

wilder.setup({ modes = { ':' } })

wilder.set_option('pipeline', {
  wilder.branch(
    wilder.cmdline_pipeline({
      language = 'vim',
      fuzzy = true,
    }),
    wilder.search_pipeline()
  )
})

wilder.set_option('renderer', wilder.popupmenu_renderer(
  wilder.popupmenu_border_theme({
    highlighter = wilder.basic_highlighter(),  -- use Lua highlighter
    border = 'rounded',
    highlights = {
      border = 'Normal',
    },
  })
))
