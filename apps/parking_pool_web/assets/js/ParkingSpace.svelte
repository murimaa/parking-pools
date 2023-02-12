<script>
    export let socket;
    export let id;
    export let number;

    let busy = true;
    let reserved = false;
    let showReservationDetails = false;
    let own = false;

    const channel = socket.channel(`parking_space:${id}`, {});
    channel.join()

    channel.on('status', function (payload) {
        busy = false;
        reserved = payload.reserved;
        // not available yet
        // own = payload.own;
        if (!reserved) own = false;
    });

    const reserve = async (e) => {
        e.preventDefault();
        const res = await fetch(`/api/space/${id}/reserve`, {
            method: "post"
        });
        payload = await res.json()
        reserved = payload.reserved;
        showReservationDetails = false;

        // Placeholder logic - this would come from websocket based on userid
        own = true;
    }
    const free = async (e) => {
        e.preventDefault();
        const res = await fetch(`/api/space/${id}/free`, {
            method: "post"
        });
        payload = await res.json()
        reserved = payload.reserved;
        showReservationDetails = false;

    }
    const flipReserved = (e) => {
        e.preventDefault();
        if (reserved) showReservationDetails = !showReservationDetails;
    }

    $: canBeFlipped = reserved
</script>
<div
  class="group transition relative rounded-xl px-14 py-14 text-sm font-semibold"
  class:sm:hover:scale-105={canBeFlipped}
>
    <!-- free space front side -->
    <span class="absolute shadow-md inset-0 rounded-xl py-1 bg-zinc-50 transition"
          class:group-hover:bg-zinc-100={canBeFlipped}
          class:flipped={reserved} style="backface-visibility: hidden; transition: transform 0.6s;">
    <span class="relative flex items-center justify-center gap-4 flex-col h-full">
        <span class="font-sans text-lg font-light">{number}</span>
        <button on:click={reserve}
                class="px-4 py-1 text-[0.6rem] font-light
                border border-rose-500
                bg-rose-300 hover:bg-rose-400 rounded-full transition sm:_hover:scale-105">Reserve</button>
    </span>
    </span>

    <!-- reserved space front side -->
    <a href="#" class="absolute shadow-md inset-0 rounded-xl py-1 bg-zinc-50 transition"
       on:click={flipReserved}
       class:group-hover:bg-zinc-100={canBeFlipped}
       class:flipped={!reserved || showReservationDetails} style="transition: transform 0.6s; backface-visibility: hidden;">
        <span class="relative flex items-center justify-center gap-4 flex-col h-full">
            <span class="text-3xl">🚘</span>
            {#if own}
                <span class="text-xs font-light text-amber-700">Your space</span>
            {/if}
        </span>
    </a>

    <!-- reserved space back side -->
    {#if reserved}
    <a href="#" class="absolute shadow-md inset-0 rounded-xl py-1 bg-zinc-50 transition"
       on:click={flipReserved}
       class:group-hover:bg-zinc-100={canBeFlipped}
       class:flipped={!showReservationDetails} style="transition: transform 0.6s; backface-visibility: hidden;">
        <span class="relative flex justify-center gap-4 flex-col h-full">
            <span class="text-sm text-center">Show some details of the reservation here!</span>
        </span>
    </a>
    {/if}
</div>
<style>
    .flipped {
        transform: rotateY(180deg)
    }
</style>
