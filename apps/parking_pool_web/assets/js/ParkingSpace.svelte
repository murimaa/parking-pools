<script>
    export let socket;
    export let id;

    let reserved = true;

    const channel = socket.channel(`parking_space:${id}`, {});
    channel.join()

    function onClick(e) {
        reserved = !reserved;
        e.preventDefault();
    }
</script>
            <a
                    on:click={onClick}
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
