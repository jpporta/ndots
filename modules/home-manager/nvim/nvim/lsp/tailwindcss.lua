return {
  cmd = { "tailwindcss-language-server", "--stdio" },
  filetypes = {
    "html", "css", "scss", "javascript", "javascriptreact",
    "typescript", "typescriptreact", "svelte", "vue", "astro",
  },
  root_markers = {
    "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.ts",
    "postcss.config.js", "package.json", ".git",
  },
  settings = {
    tailwindCSS = {
      validate = true,
      classAttributes = { "class", "className", "classList", "ngClass" },
      -- for cn()/clsx()/cva() wrappers:
      experimental = {
        classRegex = {
          { "cva%(([^)]*)%)", "[\"'`]([^\"'`]*).*?[\"'`]" },
          { "cn%(([^)]*)%)", "[\"'`]([^\"'`]*).*?[\"'`]" },
        },
      },
    },
  },
}
