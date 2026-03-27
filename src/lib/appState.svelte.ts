class AppState {
    private _isShowSettingsPage = $state(false);

    get isShowSettingsPage() {
        return this._isShowSettingsPage;
    }

    set isShowSettingsPage(value: boolean) {
        this._isShowSettingsPage = value;
    }

}

export const appState = new AppState();
