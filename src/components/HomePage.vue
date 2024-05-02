<template>
  <div
    class="m-4 flex flex-wrap justify-between gap-8 lg:m-8 lg:text-xl xl:text-base"
  >
    <div class="w-[90%] lg:w-7/12 xl:w-1/3">
      <p>
        Labore fugiat non ea voluptate tempor non occaecat nisi amet proident.
        Ipsum sint irure anim eu cillum deserunt duis ea. Duis cupidatat ullamco
        minim aliquip do eiusmod incididunt non do non. Irure voluptate deserunt
        ea ex consectetur et cillum nisi. Ut mollit minim Lorem proident velit
        irure.
      </p>

      <div class="mt-2 text-light-400 underline">
        <a class="connect-link" href="https://github.com/ehassett">GitHub</a>
        <a class="connect-link" href="https://linkedin.com/in/ehassett"
          >LinkedIn</a
        >
        <router-link class="connect-link" to="/resume">Resume</router-link>
        <a class="connect-link" href="mailto:ethan@hassett.io">Get in Touch</a>
      </div>
    </div>

    <div class="lg:w-3/12 xl:hidden"></div>
    <div class="lg:w-3/12 xl:hidden"></div>

    <div class="grid w-[90%] grid-rows-2 gap-y-4 lg:w-7/12 lg:gap-y-8 xl:w-1/3">
      <div class="grid grid-cols-2">
        <div class="text-start">Skills</div>
        <div class="text-end">
          <p>Something</p>
          <p>Something else</p>
          <p>A third thing</p>
        </div>
      </div>

      <div class="grid grid-cols-2">
        <div class="text-start">Technologies</div>
        <div class="text-end">
          <p>Something</p>
          <p>Something else</p>
          <p>A third thing</p>
        </div>
      </div>
    </div>
  </div>

  <div
    class="absolute bottom-0 ml-2 text-8xl lg:ml-4 lg:text-[10rem] 2xl:text-[14rem]"
  >
    Ethan Hassett
  </div>
</template>
