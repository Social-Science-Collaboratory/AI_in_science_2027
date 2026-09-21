# class-structure — the seminar diagram in the preface

Figure package for `@fig-seminar-structure` in `index.qmd`: the diagram of how
a single week of the seminar ran, from picking a component of the research
pipeline through to the Polis vote.

Unlike the other packages here there is no R in it. The diagram is drawn by
hand in [draw.io](https://app.diagrams.net), and the chapter includes the
exported PNG directly:

```markdown
![Structure of the UF Fall 2026 seminar, titled Collective \[Artificial\]
Intelligence in Science.](figure-packages/class-structure/figures/class-structure.png){#fig-seminar-structure fig-align="left" width="100%"}
```

## Editing it

`class-structure.drawio` is the source; `figures/class-structure.png` is the
export the book renders. Edit the source, then re-export the PNG over the old
one — **File → Export as → PNG**, transparent background off, zoom 300% so the
labels stay legible at the width the page gives it. Committing one without the
other is the failure mode to watch for: the book will happily keep rendering a
stale export.

draw.io writes a `.$class-structure.drawio.bkp` autosave beside the source
while a tab is open. It is a *previous* state, not a newer one, and `.gitignore`
holds it out of the repo.
