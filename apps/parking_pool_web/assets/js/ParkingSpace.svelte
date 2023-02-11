<script>
    export let socket;
    export let id;
    export let number;

    let busy = true;

    let reserved = false;

    const channel = socket.channel(`parking_space:${id}`, {});
    channel.join()

    channel.on('status', function (payload) {
        busy = false;
        reserved = payload.reserved;
    });

    const reserve = async (e) => {
        e.preventDefault();
        const res = await fetch(`/api/space/${id}/reserve`, {
            method: "post"
        });
        payload = await res.json()
        reserved = payload.reserved;
    }
    const free = async (e) => {
        e.preventDefault();
        const res = await fetch(`/api/space/${id}/free`, {
            method: "post"
        });
        payload = await res.json()
        reserved = payload.reserved;
    }
</script>
<a
  on:click={reserved ? free : reserve}
  href=""
  class="group relative rounded-xl px-6 py-6 text-sm font-semibold sm:py-10 sm:px-10 group-hover:bg-zinc-100 sm:group-hover:scale-105"
>
    <span class="absolute shadow-md inset-0 rounded-xl py-1 bg-zinc-100 transition"
          class:flipped={!reserved} style="transition: transform 0.6s; backface-visibility: hidden;">
    <span class="relative flex items-center justify-center gap-4 flex-col h-full">
            <span class="text-md sm:text-3xl">🚘</span>
    </span>
        </span>
    <span class="absolute shadow-md inset-0 rounded-xl py-1 bg-zinc-100 text-zinc-500 transition"
          class:flipped={reserved} style="backface-visibility: hidden; transition: transform 0.6s;">
    <span class="relative flex items-center justify-center gap-4 flex-col h-full"
    >
            <span class="font-sans text-lg font-light">{number}</span>
    </span>
    </span>
</a>
<style>
    .flipped {
        transform: rotateY(180deg)
    }
</style>
