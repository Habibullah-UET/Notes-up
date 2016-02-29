public class ENotes.Notebook : Object {
	private FileMonitor monitor;

    public string name { public get; private set; }
    public string path { public get; private set; }
    public File directory { public get; private set; }

    public List<ENotes.Page> pages;
    public List<ENotes.Notebook> sub_notebooks;

    public double r { public get; public set; default = -1; }
    public double g { public get; public set; default = -1; }
	public double b { public get; public set; default = -1; }

    public int top_id = 0;

    public Notebook (string path_) {
        this.path = path_ + "/";
        this.path = this.path.replace ("//", "/");
        directory = File.new_for_path (path);

        split_string ();
        pages = new List<ENotes.Page> ();
        sub_notebooks = new List<ENotes.Notebook> ();

        connect_monitor ();
    }

    public void refresh () {
    	this.pages = new List<ENotes.Page> ();
    	load_pages ();
    }

    public ENotes.Page add_page_from_name (string path) {
        var page = new ENotes.Page (this.path + path);
    	add_page (page);


    	return page;
    }

    public void load_pages () {
        try {
            var directory = File.new_for_path (path);
            var enumerator = directory.enumerate_children (FileAttribute.STANDARD_NAME, 0);
            FileInfo file_info;

            while ((file_info = enumerator.next_file ()) != null) {
                if (file_info.get_file_type () == FileType.DIRECTORY) {
                    var notebook = new ENotes.Notebook (file_info.get_name ());
                    sub_notebooks.append (notebook);
                } else {
                    add_page_from_name (file_info.get_name ());
                }
            }

        } catch (Error e) {}
    }

    public ENotes.Notebook rename (string new_name) {
        string nname = "%s§%s§%s§%s".printf(new_name, r.to_string(),g.to_string(),b.to_string());

        try {
            directory = directory.set_display_name (nname);
        } catch (Error e) {
            error ("Error renaming directory: %s", e.message);
        }

        var notebook = new ENotes.Notebook (this.path + nname);

        return notebook;
    }

    public void add_page (Page page) {
        CompareDataFunc<Page> page_comp = (a, b) => {
		    int d = (int) (a.ID < b.ID) - (int) (a.ID > b.ID);
		    return d;
	    };

    	this.pages.insert_sorted_with_data (page, page_comp);

        if (top_id < page.ID) {
            top_id = page.ID;
        }

    	if (page.new_page) {
            page.ID = ++top_id;
        }


    }

    private void split_string () {
        var split = directory.get_basename ().split ("§", 4);
        name = split[0].replace (ENotes.NOTES_DIR, "");
        if (split.length > 3) {
            r = double.parse (split[1]);
            g = double.parse (split[2]);
            b = double.parse (split[3]);
        }
    }

    private void connect_monitor () {
	    try {
	        monitor = directory.monitor_directory (FileMonitorFlags.SEND_MOVED);
	        monitor.changed.connect (refresh);
	    } catch (Error e) {
            error ("Error monitoring directory: %s", e.message);
        }
    }
}