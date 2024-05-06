<template>
  <div class="m-4 flex flex-wrap justify-between gap-8 lg:m-8 lg:text-xl">
    <div class="w-[90%] lg:w-7/12 xl:w-1/3">
      <p>
        Thanks for visiting! I'm a Cloud & DevOps Engineer based in the United
        States with a development and sysadmin background. I enjoy designing
        beautiful systems, improving efficiency and safety, while working with
        all aspects of a software project. I'm currently a Cloud Engineer at
        Auction Edge, open to consulting or contracting opportunities with
        clients worldwide.
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
        <div class="text-start">Cloud & DevOps</div>
        <div class="text-end">
          <p>AWS</p>
          <p>Infrastructure-as-Code</p>
          <p>CI/CD Pipelines</p>
          <p>Docker/Kubernetes</p>
          <p>Configuration Management</p>
        </div>
      </div>

      <div class="grid grid-cols-2">
        <div class="text-start">Development</div>
        <div class="text-end">
          <p>Scripting (Go, Python, Shell)</p>
          <p>Node, Vue, Rails</p>
          <p>Tailwind, Bootstrap</p>
          <p>C++, Java</p>
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
