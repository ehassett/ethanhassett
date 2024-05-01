import { createRouter, createWebHistory } from "vue-router";
import HomePage from "./components/HomePage.vue";
import ResumePage from "./components/ResumePage.vue";

// Define routes
const routes = [
  { path: "/", component: HomePage },
  { path: "/resume", component: ResumePage },
];

// Create the router instance
const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
