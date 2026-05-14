export default PersistDialog = {
  mounted() { this.el.addEventListener("close", () => delete this.el.dataset.open) },
  beforeUpdate() { this._open = this.el.open },
  updated() { if (this._open) this.el.showModal() }
}
