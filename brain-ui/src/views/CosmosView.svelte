<script lang="ts">
  import { onMount } from 'svelte'
  import { DEMO_DATA } from '../data/demo'
  import * as THREE from 'three'

  let container: HTMLDivElement
  let hoveredNode = $state<string | null>(null)
  let selectedNode = $state<string | null>(null)
  let tooltipX = $state(0)
  let tooltipY = $state(0)

  onMount(() => {
    const scene = new THREE.Scene()
    scene.background = new THREE.Color('#120a1e')
    scene.fog = new THREE.FogExp2('#120a1e', 0.04)

    const camera = new THREE.PerspectiveCamera(60, container.clientWidth / container.clientHeight, 0.1, 100)
    camera.position.set(0, 2, 12)
    camera.lookAt(0, 0, 0)

    const renderer = new THREE.WebGLRenderer({ antialias: true })
    renderer.setSize(container.clientWidth, container.clientHeight)
    renderer.setPixelRatio(window.devicePixelRatio)
    container.appendChild(renderer.domElement)

    // Ambient light
    scene.add(new THREE.AmbientLight('#404060', 0.5))

    // Point lights for glow effect
    const light1 = new THREE.PointLight('#c9a0ff', 2, 20)
    light1.position.set(5, 5, 5)
    scene.add(light1)

    const light2 = new THREE.PointLight('#9adba8', 1.5, 20)
    light2.position.set(-5, -3, 3)
    scene.add(light2)

    // Nodes as glowing spheres
    const nodeMeshes: THREE.Mesh[] = []
    const nodeMap = new Map<string, THREE.Mesh>()

    for (const node of DEMO_DATA.cosmosNodes) {
      const geo = new THREE.SphereGeometry(node.size * 0.2, 32, 32)
      const mat = new THREE.MeshPhongMaterial({
        color: new THREE.Color(node.color),
        emissive: new THREE.Color(node.color),
        emissiveIntensity: 0.4,
        transparent: true,
        opacity: 0.9,
      })
      const mesh = new THREE.Mesh(geo, mat)
      mesh.position.set(node.x, node.y, node.z)
      mesh.userData = { id: node.id, label: node.label }
      scene.add(mesh)
      nodeMeshes.push(mesh)
      nodeMap.set(node.id, mesh)
    }

    // Edges as lines
    for (const edge of DEMO_DATA.cosmosEdges) {
      const from = nodeMap.get(edge.from)
      const to = nodeMap.get(edge.to)
      if (!from || !to) continue

      const points = [from.position, to.position]
      const geo = new THREE.BufferGeometry().setFromPoints(points)
      const mat = new THREE.LineBasicMaterial({
        color: '#3d2660',
        transparent: true,
        opacity: 0.4,
      })
      scene.add(new THREE.Line(geo, mat))
    }

    // Star particles background
    const starGeo = new THREE.BufferGeometry()
    const starPositions = new Float32Array(3000)
    for (let i = 0; i < 3000; i++) {
      starPositions[i] = (Math.random() - 0.5) * 60
    }
    starGeo.setAttribute('position', new THREE.BufferAttribute(starPositions, 3))
    const starMat = new THREE.PointsMaterial({ color: '#3d2660', size: 0.05 })
    scene.add(new THREE.Points(starGeo, starMat))

    // Animation
    let time = 0
    let mouseX = 0
    let mouseY = 0
    let isDragging = false
    let rotY = 0
    let rotX = 0.2

    container.addEventListener('mousemove', (e) => {
      const rect = container.getBoundingClientRect()
      mouseX = ((e.clientX - rect.left) / rect.width) * 2 - 1
      mouseY = -((e.clientY - rect.top) / rect.height) * 2 + 1
      tooltipX = e.clientX - rect.left
      tooltipY = e.clientY - rect.top

      if (isDragging) {
        rotY += e.movementX * 0.005
        rotX += e.movementY * 0.005
        rotX = Math.max(-1, Math.min(1, rotX))
      }
    })

    container.addEventListener('mousedown', () => isDragging = true)
    container.addEventListener('mouseup', () => isDragging = false)
    container.addEventListener('mouseleave', () => isDragging = false)

    // Raycaster for hover
    const raycaster = new THREE.Raycaster()
    const mouse = new THREE.Vector2()

    container.addEventListener('mousemove', (e) => {
      const rect = container.getBoundingClientRect()
      mouse.x = ((e.clientX - rect.left) / rect.width) * 2 - 1
      mouse.y = -((e.clientY - rect.top) / rect.height) * 2 + 1
    })

    container.addEventListener('click', () => {
      raycaster.setFromCamera(mouse, camera)
      const intersects = raycaster.intersectObjects(nodeMeshes)
      if (intersects.length > 0) {
        selectedNode = intersects[0].object.userData.id
      } else {
        selectedNode = null
      }
    })

    function animate() {
      requestAnimationFrame(animate)
      time += 0.005

      // Gentle auto-rotation + mouse influence
      const targetY = rotY + time * 0.3
      const targetX = rotX

      camera.position.x = 12 * Math.sin(targetY) * Math.cos(targetX)
      camera.position.y = 12 * Math.sin(targetX) + 2
      camera.position.z = 12 * Math.cos(targetY) * Math.cos(targetX)
      camera.lookAt(0, 0, 0)

      // Pulse nodes
      for (const mesh of nodeMeshes) {
        const mat = mesh.material as THREE.MeshPhongMaterial
        mat.emissiveIntensity = 0.3 + Math.sin(time * 2 + mesh.position.x) * 0.15
      }

      // Hover detection
      raycaster.setFromCamera(mouse, camera)
      const intersects = raycaster.intersectObjects(nodeMeshes)
      hoveredNode = intersects.length > 0 ? intersects[0].object.userData.label : null

      renderer.render(scene, camera)
    }

    animate()

    // Resize handler
    const resizeObserver = new ResizeObserver(() => {
      camera.aspect = container.clientWidth / container.clientHeight
      camera.updateProjectionMatrix()
      renderer.setSize(container.clientWidth, container.clientHeight)
    })
    resizeObserver.observe(container)

    return () => {
      resizeObserver.disconnect()
      renderer.dispose()
    }
  })

  const selectedData = $derived(
    selectedNode ? DEMO_DATA.cosmosNodes.find(n => n.id === selectedNode) : null
  )
  const connectedCount = $derived(
    selectedNode ? DEMO_DATA.cosmosEdges.filter(e => e.from === selectedNode || e.to === selectedNode).length : 0
  )
</script>

<div class="relative h-full">
  <div bind:this={container} class="w-full h-full cursor-grab active:cursor-grabbing"></div>

  <!-- Hover tooltip follows mouse -->
  {#if hoveredNode}
    <div
      class="absolute bg-[var(--bg-secondary)]/95 backdrop-blur
        border border-[var(--border)] rounded-lg px-3 py-1.5 text-sm pointer-events-none
        shadow-lg"
      style="left: {tooltipX + 16}px; top: {tooltipY - 12}px;"
    >
      {hoveredNode}
    </div>
  {/if}

  <!-- Info panel -->
  {#if selectedData}
    <div class="absolute bottom-6 right-6 bg-[var(--bg-secondary)]/95 backdrop-blur
      border border-[var(--border)] rounded-lg p-5 w-72">
      <div class="flex items-center gap-3 mb-3">
        <div class="w-3 h-3 rounded-full" style="background: {selectedData.color}"></div>
        <h3 class="font-semibold">{selectedData.label}</h3>
      </div>
      <div class="text-xs text-[var(--text-secondary)] space-y-1">
        <div>Position: ({selectedData.x}, {selectedData.y}, {selectedData.z})</div>
        <div>Connexions: {connectedCount}</div>
        <div>Taille: {selectedData.size}</div>
      </div>
    </div>
  {/if}

  <!-- Legend -->
  <div class="absolute top-4 right-4 bg-[var(--bg-secondary)]/80 backdrop-blur
    border border-[var(--border)] rounded-lg p-4 text-xs">
    <div class="font-medium mb-2">Cosmos — Brain Map</div>
    <div class="space-y-1 text-[var(--text-secondary)]">
      <div>Clic : selectionner un noeud</div>
      <div>Glisser : orbiter</div>
      <div>{DEMO_DATA.cosmosNodes.length} noeuds — {DEMO_DATA.cosmosEdges.length} connexions</div>
    </div>
  </div>
</div>
