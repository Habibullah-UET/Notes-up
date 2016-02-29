

public class ENotes.Sidebar : Granite.Widgets.SourceList {

    private Granite.Widgets.SourceList.ExpandableItem notebooks = new Granite.Widgets.SourceList.ExpandableItem (_("Notebooks"));
    private Granite.Widgets.SourceList.ExpandableItem bookmarks = new Granite.Widgets.SourceList.ExpandableItem (_("Bookmarks"));

    public Sidebar () {
        build_new_ui ();
        load_notebooks ();
        load_bookmarks ();
        connect_signals ();
        notebooks.collapse_all (true, true);
     	root.expand_all (false, false);
    }

	private void build_new_ui () {
		root.add (notebooks);
		root.add (bookmarks);

        can_focus = false;
		this.width_request = 150;
	}

    public void load_notebooks () {
        this.notebooks.clear ();

        var notebook_list = FileManager.load_notebooks ();

       	foreach (ENotes.Notebook nb in notebook_list) {
			var notebook = new NotebookItem (nb);
			this.notebooks.add (notebook);

			load_sub_notebooks (notebook);
		}
    }

    public void load_sub_notebooks (NotebookItem item) {
        if (item.notebook.sub_notebooks.length () > 0) {
            foreach (ENotes.Notebook nb in item.notebook.sub_notebooks) {
			    var new_item = new NotebookItem (nb);
			    item.add (new_item);

			    load_sub_notebooks (new_item);
			    item.collapse_all ();
		    }
        }
    }

    public void load_bookmarks () {
        this.bookmarks.clear ();

        var bookmark_list = FileManager.load_bookmarks ();

       	foreach (string bm in bookmark_list) {
			var bookmark = new BookmarkItem (bm);
			this.bookmarks.add (bookmark);
		}

		bookmarks.expand_all ();
    }

    public void select_notebook (string name) {
		foreach (var notebook in notebooks.children ) {
			if (notebook.name == name) {
		        selected = notebook;
		        return;
			}
		}
    }

    public void first_start () {
        if (notebooks.children.is_empty) {
		    first_notebook ();
		}
    }

    private void first_notebook () {
        var dir = FileManager.create_notebook ("Unamed Notebook", 1, 0, 0);
        var notebook = new ENotes.Notebook (ENotes.NOTES_DIR + dir);

        var notebook_item = new NotebookItem (notebook);
		this.notebooks.add (notebook_item);

		select_notebook (notebook.name);
    }

    private void connect_signals () {
		 this.item_selected.connect ((item) => {
		 	if (item == null) return;

		 	if (item is BookmarkItem) {
		 	    editor.load_file (((ENotes.BookmarkItem) item).page);
		 	    select_notebook (((ENotes.BookmarkItem) item).parent_notebook.name);
		 	    return;
		 	} else {
		 	    ((NotebookItem) item).expand_all (true, true);
		 	}

            editor.save_file ();
     	    pages_list.load_pages (((ENotes.NotebookItem) item).notebook);
     	});
    }
}