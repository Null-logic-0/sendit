export default AutoGrow = {
  mounted() {
    this.grow();
    this.el.addEventListener("input", () => this.grow());
  },
  updated() {
    this.grow();
  },
  grow() {
    this.el.style.height = "auto";
    this.el.style.height = this.el.scrollHeight + "px";
  }
};
