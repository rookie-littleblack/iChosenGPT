# DO NOT add any comments in the css setting!
CSS = r"""
.modal-box {
  position: fixed !important;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%); /* center horizontally */
  max-width: 1000px;
  max-height: 750px;
  background-color: var(--input-background-fill);
  border: 2px solid black !important;
  z-index: 1000;
  padding: 10px;
}

.dark .modal-box {
  border: 2px solid white !important;
}

.avatar-container{
  box-shadow: 2px 2px 5px #d1d1d1 !important;
  border-radius: 50% !important;
  width: 55px !important;
  height: 55px !important;
}
.user{
  background-color: #bafff5 !important;
  border-color: #bafff5 !important;
  box-shadow: 2px 2px 5px #d1d1d1 !important;
}
.bot{
  background-color: #fff4ca !important;
  border-color: #fff4ca !important;
  box-shadow: 2px 2px 5px #d1d1d1 !important;
}

footer{
  display: none !important;
}

.chatbot{
  user-select: text !important;
  cursor: text !important;
}
"""
