<script lang="ts">
  import { DEMO_DATA } from '../data/demo'
  import { marked } from 'marked'

  let selectedDoc = $state(DEMO_DATA.docsList[0])
  let content = $state('')
  let loading = $state(false)

  async function loadDoc(doc: typeof DEMO_DATA.docsList[0]) {
    selectedDoc = doc
    loading = true
    try {
      const res = await fetch(`${import.meta.env.BASE_URL}docs/${doc.file}`)
      if (res.ok) {
        let text = await res.text()
        // Strip YAML frontmatter (--- ... ---)
        text = text.replace(/^---\n[\s\S]*?\n---\n*/, '')
        content = marked(text) as string
      } else {
        content = `<p class="text-[var(--text-secondary)]">Document non disponible. Placez vos docs dans <code>brain-ui/dist/docs/</code></p>`
      }
    } catch {
      content = `<p class="text-[var(--text-secondary)]">Erreur de chargement.</p>`
    }
    loading = false
  }

  // Load first doc on mount
  $effect(() => {
    loadDoc(DEMO_DATA.docsList[0])
  })
</script>

<div class="flex h-full">
  <!-- Doc sidebar -->
  <div class="w-64 bg-[var(--bg-secondary)] border-r border-[var(--border)] overflow-y-auto">
    <div class="px-4 py-4 border-b border-[var(--border)]">
      <h2 class="text-sm font-semibold">Documentation</h2>
      <p class="text-xs text-[var(--text-secondary)] mt-0.5">{DEMO_DATA.docsList.length} pages</p>
    </div>
    <nav class="py-2">
      {#each DEMO_DATA.docsList as doc}
        <button
          class="w-full px-4 py-2 text-left text-sm transition-colors
            {selectedDoc.id === doc.id
              ? 'bg-[var(--accent)]/10 text-[var(--accent)]'
              : 'text-[var(--text-secondary)] hover:text-[var(--text-primary)] hover:bg-[var(--bg-tertiary)]'}"
          onclick={() => loadDoc(doc)}
        >
          {doc.title}
        </button>
      {/each}
    </nav>
  </div>

  <!-- Doc content -->
  <div class="flex-1 overflow-y-auto p-8 max-w-4xl">
    {#if loading}
      <div class="text-[var(--text-secondary)]">Chargement...</div>
    {:else}
      <article class="prose prose-invert prose-sm max-w-none
        [&_h1]:text-2xl [&_h1]:font-bold [&_h1]:mb-4 [&_h1]:text-[var(--text-primary)]
        [&_h2]:text-xl [&_h2]:font-semibold [&_h2]:mt-8 [&_h2]:mb-3 [&_h2]:text-[var(--text-primary)]
        [&_h3]:text-lg [&_h3]:font-medium [&_h3]:mt-6 [&_h3]:mb-2 [&_h3]:text-[var(--text-primary)]
        [&_p]:text-[var(--text-secondary)] [&_p]:mb-3 [&_p]:leading-relaxed
        [&_ul]:list-disc [&_ul]:pl-6 [&_ul]:text-[var(--text-secondary)] [&_ul]:mb-3
        [&_ol]:list-decimal [&_ol]:pl-6 [&_ol]:text-[var(--text-secondary)] [&_ol]:mb-3
        [&_li]:mb-1
        [&_code]:bg-[var(--bg-tertiary)] [&_code]:px-1.5 [&_code]:py-0.5 [&_code]:rounded [&_code]:text-[var(--accent)] [&_code]:text-xs
        [&_pre]:bg-[var(--bg-tertiary)] [&_pre]:p-4 [&_pre]:rounded-lg [&_pre]:overflow-x-auto [&_pre]:mb-4
        [&_pre_code]:bg-transparent [&_pre_code]:p-0 [&_pre_code]:text-[var(--text-primary)]
        [&_table]:w-full [&_table]:mb-4
        [&_th]:text-left [&_th]:px-3 [&_th]:py-2 [&_th]:border-b [&_th]:border-[var(--border)] [&_th]:text-sm [&_th]:font-medium
        [&_td]:px-3 [&_td]:py-2 [&_td]:border-b [&_td]:border-[var(--border)] [&_td]:text-sm [&_td]:text-[var(--text-secondary)]
        [&_a]:text-[var(--accent)] [&_a]:underline
        [&_blockquote]:border-l-2 [&_blockquote]:border-[var(--accent)] [&_blockquote]:pl-4 [&_blockquote]:italic [&_blockquote]:text-[var(--text-secondary)]
        [&_hr]:border-[var(--border)] [&_hr]:my-6
        [&_strong]:text-[var(--text-primary)]">
        {@html content}
      </article>
    {/if}
  </div>
</div>
