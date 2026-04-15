export default function HomePage() {
  return (
    <main className="min-h-screen bg-black text-white">
      <div className="mx-auto max-w-6xl px-6 py-16">
        <div className="mb-10">
          <p className="text-sm uppercase tracking-[0.3em] text-zinc-500">Viatori</p>
          <h1 className="mt-4 text-5xl font-semibold tracking-tight">Modern social video platform</h1>
          <p className="mt-4 max-w-2xl text-zinc-400">
            iOS referans app baz alınarak sıfırdan kurulan yeni web iskeleti.
          </p>
        </div>

        <div className="grid gap-6 md:grid-cols-4">
          <div className="rounded-2xl border border-zinc-800 bg-zinc-950 p-5">Feed</div>
          <div className="rounded-2xl border border-zinc-800 bg-zinc-950 p-5">Messages</div>
          <div className="rounded-2xl border border-zinc-800 bg-zinc-950 p-5">Profile</div>
          <div className="rounded-2xl border border-zinc-800 bg-zinc-950 p-5">Explore</div>
        </div>

        <div className="mt-10 grid gap-6 lg:grid-cols-[260px_1fr_320px]">
          <aside className="rounded-2xl border border-zinc-800 bg-zinc-950 p-5">
            Left Navigation
          </aside>

          <section className="rounded-2xl border border-zinc-800 bg-zinc-950 p-5">
            Main Feed Area
          </section>

          <aside className="rounded-2xl border border-zinc-800 bg-zinc-950 p-5">
            Right Sidebar
          </aside>
        </div>
      </div>
    </main>
  );
}
