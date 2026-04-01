<script lang="ts">
  import { DEMO_DATA } from '../data/demo'

  const stats = [
    { label: 'Agents', value: DEMO_DATA.agents.total, sub: `${DEMO_DATA.agents.free} free / ${DEMO_DATA.agents.pro} pro`, color: 'var(--accent)' },
    { label: 'Sessions', value: DEMO_DATA.sessions, sub: '4 types disponibles', color: 'var(--blue)' },
    { label: 'Scripts', value: DEMO_DATA.scripts, sub: 'framework + outils', color: 'var(--green)' },
    { label: 'Docs', value: DEMO_DATA.docs, sub: 'pages humaines', color: 'var(--yellow)' },
  ]

  const projects = DEMO_DATA.projects
  const recentActivity = DEMO_DATA.activity
</script>

<div class="p-8 max-w-6xl">
  <header class="mb-8">
    <h1 class="text-2xl font-bold">Dashboard</h1>
    <p class="text-[var(--text-secondary)] text-sm mt-1">Vue d'ensemble de votre brain</p>
  </header>

  <!-- Stats cards -->
  <div class="grid grid-cols-4 gap-4 mb-8">
    {#each stats as stat}
      <div class="bg-[var(--bg-secondary)] rounded-lg p-5 border border-[var(--border)]">
        <div class="text-3xl font-bold" style="color: {stat.color}">{stat.value}</div>
        <div class="text-sm font-medium mt-1">{stat.label}</div>
        <div class="text-xs text-[var(--text-secondary)] mt-0.5">{stat.sub}</div>
      </div>
    {/each}
  </div>

  <div class="grid grid-cols-2 gap-6">
    <!-- Projects -->
    <div class="bg-[var(--bg-secondary)] rounded-lg border border-[var(--border)]">
      <div class="px-5 py-4 border-b border-[var(--border)]">
        <h2 class="text-sm font-semibold">Projets</h2>
      </div>
      <div class="divide-y divide-[var(--border)]">
        {#each projects as project}
          <div class="px-5 py-3 flex items-center justify-between">
            <div>
              <div class="text-sm font-medium">{project.name}</div>
              <div class="text-xs text-[var(--text-secondary)]">{project.description}</div>
            </div>
            <span class="text-xs px-2 py-1 rounded-full
              {project.status === 'scaffold' ? 'bg-[var(--yellow)]/10 text-[var(--yellow)]' :
               project.status === 'active' ? 'bg-[var(--green)]/10 text-[var(--green)]' :
               'bg-[var(--text-secondary)]/10 text-[var(--text-secondary)]'}">
              {project.status}
            </span>
          </div>
        {/each}
      </div>
    </div>

    <!-- Activity -->
    <div class="bg-[var(--bg-secondary)] rounded-lg border border-[var(--border)]">
      <div class="px-5 py-4 border-b border-[var(--border)]">
        <h2 class="text-sm font-semibold">Activite recente</h2>
      </div>
      <div class="divide-y divide-[var(--border)]">
        {#each recentActivity as item}
          <div class="px-5 py-3">
            <div class="text-sm">{item.action}</div>
            <div class="text-xs text-[var(--text-secondary)] mt-0.5">{item.time}</div>
          </div>
        {/each}
      </div>
    </div>
  </div>

  <!-- Tier info -->
  <div class="mt-6 bg-[var(--bg-secondary)] rounded-lg border border-[var(--border)] p-5">
    <div class="flex items-center gap-3 mb-3">
      <span class="text-xs px-2 py-1 rounded bg-[var(--accent)]/10 text-[var(--accent)] font-medium">FREE</span>
      <span class="text-sm text-[var(--text-secondary)]">{DEMO_DATA.agents.free} agents disponibles</span>
    </div>
    <div class="flex gap-8 text-sm">
      <div>
        <span class="text-[var(--green)]">✓</span> Dashboard
        <span class="text-[var(--green)] ml-4">✓</span> Documentation
        <span class="text-[var(--green)] ml-4">✓</span> Cosmos
        <span class="text-[var(--green)] ml-4">✓</span> Sessions
      </div>
      <div class="text-[var(--text-secondary)]">
        <span class="opacity-50">⬡</span> Agents avances (pro)
        <span class="opacity-50 ml-4">⬡</span> Distillation (full)
      </div>
    </div>
  </div>
</div>
