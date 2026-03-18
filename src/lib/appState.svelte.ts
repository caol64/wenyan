class AppState {
    private _isShowMoreMenu = $state(false);
    private _isShowSettingsPage = $state(false);
    private _isShowAboutPage = $state(false);
    private _isShowFileSidebar = $state(false);

    get isShowMoreMenu() {
        return this._isShowMoreMenu;
    }

    set isShowMoreMenu(value: boolean) {
        this._isShowMoreMenu = value;
    }

    get isShowSettingsPage() {
        return this._isShowSettingsPage;
    }

    set isShowSettingsPage(value: boolean) {
        this._isShowSettingsPage = value;
        this._isShowMoreMenu = false;
    }

    get isShowAboutPage() {
        return this._isShowAboutPage;
    }

    set isShowAboutPage(value: boolean) {
        this._isShowAboutPage = value;
        this._isShowMoreMenu = false;
    }

    get isShowFileSidebar() {
        return this._isShowFileSidebar;
    }

    set isShowFileSidebar(value: boolean) {
        this._isShowFileSidebar = value;
    }
}

export const appState = new AppState();
