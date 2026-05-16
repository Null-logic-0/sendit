export default ScrollToBottom = {
  mounted() {
    this.scrollToBottom();
  },
  updated() {
    const el = this.el;
    const nearBottom = el.scrollHeight - el.scrollTop - el.clientHeight < 100;
    if (nearBottom) this.scrollToBottom();
  },
  scrollToBottom() {
    this.el.scrollTop = this.el.scrollHeight;
  }
};
