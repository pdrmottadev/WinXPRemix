// WinXPRemix: tela de bloqueio
//
// Ao bloquear, o Shell entra no modo "unlock-dialog" e desativa as extensões
// que não declaram esse modo. A User Themes é uma delas, e o disable() dela
// volta o Shell ao tema padrão. Esta extensão declara o modo e, só enquanto a
// tela está bloqueada, reaplica a folha de estilo do WinXPRemix escolhida na
// User Themes. Fora do bloqueio ela não faz nada.

import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';

const USER_THEME_SCHEMA = 'org.gnome.shell.extensions.user-theme';

function winxpStylesheet() {
    const source = Gio.SettingsSchemaSource.get_default();
    if (!source.lookup(USER_THEME_SCHEMA, true))
        return null;

    const name = new Gio.Settings({schema_id: USER_THEME_SCHEMA}).get_string('name');
    if (!name.startsWith('WinXPRemix'))
        return null;

    // Mesma ordem de busca da User Themes
    const dirs = [
        GLib.build_filenamev([GLib.get_home_dir(), '.themes']),
        GLib.build_filenamev([GLib.get_user_data_dir(), 'themes']),
        ...GLib.get_system_data_dirs().map(dir => GLib.build_filenamev([dir, 'themes'])),
    ];
    for (const dir of dirs) {
        const file = Gio.File.new_for_path(GLib.build_filenamev([dir, name, 'gnome-shell', 'gnome-shell.css']));
        if (file.query_exists(null))
            return file;
    }
    return null;
}

export default class WinXPRemixLockScreen extends Extension {
    enable() {
        this._applied = false;
        this._sessionId = Main.sessionMode.connect('updated', () => this._queueSync());
        this._queueSync();
    }

    disable() {
        Main.sessionMode.disconnect(this._sessionId);
        if (this._idleId)
            GLib.source_remove(this._idleId);
        this._idleId = 0;

        // Só desfaz se fomos nós que aplicamos (tela ainda bloqueada)
        if (this._applied) {
            Main.setThemeStylesheet(null);
            Main.loadTheme();
        }
        this._applied = false;
    }

    // Roda depois que o gerenciador de extensões já desativou a User Themes
    _queueSync() {
        if (this._idleId)
            return;
        this._idleId = GLib.idle_add(GLib.PRIORITY_DEFAULT, () => {
            this._idleId = 0;
            this._sync();
            return GLib.SOURCE_REMOVE;
        });
    }

    _sync() {
        if (Main.sessionMode.currentMode !== 'unlock-dialog') {
            // De volta à sessão: a User Themes reaplica o tema sozinha
            this._applied = false;
            return;
        }

        const stylesheet = winxpStylesheet();
        if (!stylesheet)
            return;

        Main.setThemeStylesheet(stylesheet.get_path());
        Main.loadTheme();
        this._applied = true;
    }
}
