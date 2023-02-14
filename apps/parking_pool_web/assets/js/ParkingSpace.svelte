<script>
    export let socket;
    export let id;
    export let number;

    let busy = true;
    let reserved = false;
    let showReservationDetails = false;
    let own = false;
    let name = '';

    const channel = socket.channel(`parking_space:${id}`, {});
    channel.join()

    channel.on('status', function (payload) {
        busy = false;
        reserved = payload.reserved;
        own = payload.own;
        name = payload.reserved_by_name;
    });

    const reserve = async (e) => {
        e.preventDefault();
        const res = await fetch(`/api/space/${id}/reserve`, {
            method: "post"
        });
        payload = await res.json()
        reserved = payload.reserved;
        if (reserved) own = true;
        showReservationDetails = false;

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
        if (canBeFlipped) showReservationDetails = !showReservationDetails;
    }

    $: canBeFlipped = reserved && !own
</script>
<div
  class="group transition relative rounded-xl px-14 py-14 text-sm font-semibold"
  class:sm:hover:scale-105={canBeFlipped}
>
    <!-- free space front side -->
    <div class="absolute shadow-md inset-0 rounded-xl py-1 bg-zinc-50 transition"
          class:group-hover:bg-zinc-100={canBeFlipped}
          class:flipped={reserved} style="backface-visibility: hidden; transition: transform 0.6s;">
    <span class="relative flex items-center justify-center gap-4 flex-col h-full">
        <span class="font-sans text-lg font-light">{number}</span>
        <button on:click={reserve}
                class="px-4 py-1 text-[0.6rem] font-light
                border border-rose-500
                bg-rose-300 hover:bg-rose-400 rounded-full transition sm:_hover:scale-105">Reserve</button>
    </span>
    </div>

    <!-- reserved space front side -->
    <div class="absolute shadow-md inset-0 rounded-xl py-1 bg-zinc-50 transition"
         on:click={flipReserved}
         class:group-hover:bg-zinc-100={canBeFlipped}
         class:cursor-pointer={canBeFlipped}
         class:flipped={!reserved || showReservationDetails} style="transition: transform 0.6s; backface-visibility: hidden;">
        <span class="relative flex items-center justify-center gap-1 flex-col h-full">
            {#if own}
                <span class="text-xs font-light text-amber-700">Your space</span>
                <span class="text-3xl">🚘</span>
                <button on:click={free}
                        class="px-4 py-0 text-[0.6rem] font-light
                                border border-emerald-500
                                bg-emerald-300 hover:bg-emerald-400 rounded-full transition sm:_hover:scale-105">Free</button>

            {:else}
                <span class="text-3xl">🚘</span>
            {/if}
        </span>
    </div>

    <!-- reserved space back side -->
    {#if reserved}
    <div class="absolute cursor-pointer shadow-md inset-0 rounded-xl py-1 bg-zinc-50 transition"
       on:click={flipReserved}
       class:group-hover:bg-zinc-100={canBeFlipped}
       class:flipped={!showReservationDetails} style="transition: transform 0.6s; backface-visibility: hidden;">
        <span class="relative flex justify-center gap-4 flex-col h-full">
            <span class="text-sm text-center">{name}</span>
        </span>
    </div>
    {/if}
</div>
<style>
    .flipped {
        transform: rotateY(180deg)
    }
</style>
