<script>
    export let socket;
    export let id;

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
  class="group relative rounded-xl px-6 py-6 text-sm font-semibold text-zinc-900 sm:py-10 sm:px-10"
>
    <span class="absolute shadow-md inset-0 rounded-xl py-1 bg-zinc-50 transition group-hover:bg-zinc-100 sm:group-hover:scale-105">
    <span class="relative flex items-center justify-center gap-4 flex-col h-full">
        {#if reserved}
            <span class="text-md sm:text-3xl">🚘</span>
        {:else}
            <span class="font-sans text-xs font-light">free!</span>
        {/if}
    </span>
    </span>
</a>
<style>
</style>
