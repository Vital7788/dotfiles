return {
  settings = {
    pylsp = {
      configurationSources = {"flake8"},
      plugins = {
        pycodestyle = {enabled = false},
        --flake8 = {enabled = true},
        jedi_completion = {fuzzy = true},
        rope_autoimport = {enabled = true}
      }
    },
    python = {
      analysis = {
        autoImportCompletions = true
      }
    }
  }
}
