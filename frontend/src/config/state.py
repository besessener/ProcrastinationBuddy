import streamlit as st
from config.constants import SETTINGS
from utils.settings_api import load_settings


def configure_states():
    st.session_state.setdefault("running", False)
    st.session_state.setdefault("feedback_filter", False)
    st.session_state.setdefault("keep_favorites", True)
    st.session_state.setdefault("page_number", 1)
    st.session_state.setdefault("old_page_number", 1)
    st.session_state.setdefault("show_help_dialog", False)
    st.session_state.setdefault("show_settings_dialog", False)

    backend_settings = load_settings()
    if backend_settings:
        st.session_state.settings = backend_settings
    else:
        st.session_state.settings = SETTINGS
