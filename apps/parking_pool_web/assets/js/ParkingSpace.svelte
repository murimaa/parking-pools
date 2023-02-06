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
                    class="group relative rounded-2xl px-6 py-4 text-sm font-semibold leading-6 text-zinc-900 sm:py-6"
            >
            <span class="absolute inset-0 rounded-2xl bg-zinc-50 transition group-hover:bg-zinc-100 sm:group-hover:scale-105">
            </span>
                <span class="relative flex items-center gap-4 sm:flex-col">
                    {reserved ? '🚘' : ''}
                </span>
            </a>
<style>
</style>
