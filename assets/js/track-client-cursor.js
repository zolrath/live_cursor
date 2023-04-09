let throttleTimer;
const throttle = (callback, time) => {
  if (throttleTimer) return;
  throttleTimer = true;
  setTimeout(() => {
    callback();
    throttleTimer = false;
  }, time);
};

export default {
  mounted() {
    document.addEventListener("mousemove", (e) => {
      // Get the cursor position in % of the window
      // This has an issue, the cursors position is relative to the window so users
      // with different screen sizes will have different positions
      const x = (e.pageX / window.innerWidth) * 100; // in %
      const y = (e.pageY / window.innerHeight) * 100; // in %

      document.documentElement.style.setProperty("--x", `${x}%`);
      document.documentElement.style.setProperty("--y", `${y}%`);

      // Throttle function to only send events every 30ms to avoid flooding the server.
      throttle(
        () => this.pushEventTo(this.el.parentElement, "cursor-move", { x, y }),
        75
      );
    });
  },
};
