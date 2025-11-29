const std = @import("std");
const argsparse = @import("argonaut");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Root parser - cloud CLI simulator
    const parser = try argsparse.newParser(allocator, "cloud", "Modern cloud infrastructure management tool");
    defer parser.deinit();

    var verbose_opts = argsparse.Options{ .help = "Enable verbose output" };
    const global_verbose = try parser.flag("v", "verbose", &verbose_opts);

    // Level 1: compute command
    const compute_cmd = try parser.newCommand("compute", "Manage compute resources");
    
    // Level 2: compute -> instances
    const instances_cmd = try compute_cmd.newCommand("instances", "Manage virtual machine instances");
    
    // Level 3: compute -> instances -> create
    const inst_create_cmd = try instances_cmd.newCommand("create", "Create a new instance");
    var inst_name_opts = argsparse.Options{ .required = true, .help = "Instance name" };
    const inst_name = try inst_create_cmd.string("n", "name", &inst_name_opts);
    var machine_type_opts = argsparse.Options{ .help = "Machine type", .default_string = "e2-medium" };
    const machine_type = try inst_create_cmd.string("t", "type", &machine_type_opts);
    const inst_preemptible = try inst_create_cmd.flag("p", "preemptible", null);
    
    // Level 3: compute -> instances -> delete
    const inst_delete_cmd = try instances_cmd.newCommand("delete", "Delete an instance");
    var del_name_opts = argsparse.Options{ .required = true, .help = "Instance name to delete" };
    const del_name = try inst_delete_cmd.string("n", "name", &del_name_opts);
    const inst_force_delete = try inst_delete_cmd.flag("f", "force", null);
    
    // Level 3: compute -> instances -> list
    const inst_list_cmd = try instances_cmd.newCommand("list", "List all instances");
    var zone_opts = argsparse.Options{ .help = "Filter by zone" };
    const list_zone = try inst_list_cmd.string("z", "zone", &zone_opts);
    const list_running_only = try inst_list_cmd.flag("", "running-only", null);
    
    // Level 2: compute -> disks
    const disks_cmd = try compute_cmd.newCommand("disks", "Manage persistent disks");
    
    // Level 3: compute -> disks -> create
    const disk_create_cmd = try disks_cmd.newCommand("create", "Create a new disk");
    var disk_name_opts = argsparse.Options{ .required = true, .help = "Disk name" };
    const disk_name = try disk_create_cmd.string("n", "name", &disk_name_opts);
    var disk_size_opts = argsparse.Options{ .help = "Disk size in GB", .default_int = 100 };
    const disk_size = try disk_create_cmd.int("s", "size", &disk_size_opts);
    var disk_type_opts = argsparse.Options{ .help = "Disk type (pd-standard, pd-ssd)", .default_string = "pd-standard" };
    const disk_type = try disk_create_cmd.string("", "type", &disk_type_opts);
    
    // Level 3: compute -> disks -> snapshot
    const disk_snapshot_cmd = try disks_cmd.newCommand("snapshot", "Manage disk snapshots");
    
    // Level 4: compute -> disks -> snapshot -> create
    const snap_create_cmd = try disk_snapshot_cmd.newCommand("create", "Create disk snapshot");
    var snap_disk_opts = argsparse.Options{ .required = true, .help = "Source disk name" };
    const snap_disk = try snap_create_cmd.string("", "disk", &snap_disk_opts);
    var snap_name_opts = argsparse.Options{ .required = true, .help = "Snapshot name" };
    const snap_name = try snap_create_cmd.string("n", "name", &snap_name_opts);
    
    // Level 4: compute -> disks -> snapshot -> restore
    const snap_restore_cmd = try disk_snapshot_cmd.newCommand("restore", "Restore from snapshot");
    var restore_snap_opts = argsparse.Options{ .required = true, .help = "Snapshot name" };
    const restore_snap = try snap_restore_cmd.string("", "snapshot", &restore_snap_opts);
    var restore_disk_opts = argsparse.Options{ .required = true, .help = "Target disk name" };
    const restore_disk = try snap_restore_cmd.string("", "disk", &restore_disk_opts);
    
    // Level 1: storage command
    const storage_cmd = try parser.newCommand("storage", "Manage object storage");
    
    // Level 2: storage -> buckets
    const buckets_cmd = try storage_cmd.newCommand("buckets", "Manage storage buckets");
    
    // Level 3: storage -> buckets -> create
    const bucket_create_cmd = try buckets_cmd.newCommand("create", "Create a new bucket");
    var bucket_name_opts = argsparse.Options{ .required = true, .help = "Bucket name" };
    const bucket_name = try bucket_create_cmd.string("n", "name", &bucket_name_opts);
    var location_opts = argsparse.Options{ .help = "Bucket location", .default_string = "us-central1" };
    const bucket_location = try bucket_create_cmd.string("l", "location", &location_opts);
    const bucket_versioning = try bucket_create_cmd.flag("", "versioning", null);
    
    // Level 3: storage -> buckets -> objects
    const objects_cmd = try buckets_cmd.newCommand("objects", "Manage bucket objects");
    
    // Level 4: storage -> buckets -> objects -> upload
    const obj_upload_cmd = try objects_cmd.newCommand("upload", "Upload object to bucket");
    var upload_file_opts = argsparse.Options{ .required = true, .help = "Local file path" };
    const upload_file = try obj_upload_cmd.string("f", "file", &upload_file_opts);
    var upload_bucket_opts = argsparse.Options{ .required = true, .help = "Target bucket" };
    const upload_bucket = try obj_upload_cmd.string("b", "bucket", &upload_bucket_opts);
    const upload_public = try obj_upload_cmd.flag("", "public", null);
    
    // Level 1: database command
    const database_cmd = try parser.newCommand("database", "Manage database services");
    
    // Level 2: database -> sql
    const sql_cmd = try database_cmd.newCommand("sql", "Manage SQL databases");
    
    // Level 3: database -> sql -> instances
    const db_instances_cmd = try sql_cmd.newCommand("instances", "Manage database instances");
    
    // Level 4: database -> sql -> instances -> create
    const db_create_cmd = try db_instances_cmd.newCommand("create", "Create database instance");
    var db_name_opts = argsparse.Options{ .required = true, .help = "Database instance name" };
    const db_name = try db_create_cmd.string("n", "name", &db_name_opts);
    var db_tier_opts = argsparse.Options{ .help = "Database tier", .default_string = "db-n1-standard-1" };
    const db_tier = try db_create_cmd.string("", "tier", &db_tier_opts);
    const db_ha = try db_create_cmd.flag("", "high-availability", null);
    
    // Level 4: database -> sql -> instances -> backups
    const db_backups_cmd = try db_instances_cmd.newCommand("backups", "Manage instance backups");
    
    // Level 5: database -> sql -> instances -> backups -> create
    const backup_create_cmd = try db_backups_cmd.newCommand("create", "Create manual backup");
    var backup_inst_opts = argsparse.Options{ .required = true, .help = "Database instance name" };
    const backup_inst = try backup_create_cmd.string("", "instance", &backup_inst_opts);
    var backup_desc_opts = argsparse.Options{ .help = "Backup description" };
    const backup_desc = try backup_create_cmd.string("d", "description", &backup_desc_opts);
    
    // Parse arguments
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    parser.parse(args) catch |err| {
        std.debug.print("Error: {}\n\n", .{err});
        const usage_text = try parser.usage(null);
        defer allocator.free(usage_text);
        std.debug.print("{s}", .{usage_text});
        std.process.exit(1);
    };

    // Handle commands with proper nesting checks
    if (global_verbose.*) {
        std.debug.print("[VERBOSE MODE ENABLED]\n\n", .{});
    }

    // Compute commands
    if (compute_cmd.happened) {
        std.debug.print("=== COMPUTE RESOURCE MANAGEMENT ===\n", .{});
        
        if (instances_cmd.happened) {
            std.debug.print("→ Managing VM Instances\n", .{});
            
            if (inst_create_cmd.happened) {
                std.debug.print("  → Creating instance: {s}\n", .{inst_name.*});
                std.debug.print("    Machine type: {s}\n", .{machine_type.*});
                if (inst_preemptible.*) {
                    std.debug.print("    Mode: Preemptible (cost-optimized)\n", .{});
                }
            } else if (inst_delete_cmd.happened) {
                std.debug.print("  → Deleting instance: {s}\n", .{del_name.*});
                if (inst_force_delete.*) {
                    std.debug.print("    Force delete: YES (bypassing safety checks)\n", .{});
                }
            } else if (inst_list_cmd.happened) {
                std.debug.print("  → Listing instances\n", .{});
                if (list_zone.*.len > 0) {
                    std.debug.print("    Zone filter: {s}\n", .{list_zone.*});
                }
                if (list_running_only.*) {
                    std.debug.print("    Filter: Running instances only\n", .{});
                }
            }
        } else if (disks_cmd.happened) {
            std.debug.print("→ Managing Persistent Disks\n", .{});
            
            if (disk_create_cmd.happened) {
                std.debug.print("  → Creating disk: {s}\n", .{disk_name.*});
                std.debug.print("    Size: {}GB\n", .{disk_size.*});
                std.debug.print("    Type: {s}\n", .{disk_type.*});
            } else if (disk_snapshot_cmd.happened) {
                std.debug.print("  → Snapshot Management\n", .{});
                
                if (snap_create_cmd.happened) {
                    std.debug.print("    → Creating snapshot\n", .{});
                    std.debug.print("      Source disk: {s}\n", .{snap_disk.*});
                    std.debug.print("      Snapshot name: {s}\n", .{snap_name.*});
                } else if (snap_restore_cmd.happened) {
                    std.debug.print("    → Restoring from snapshot\n", .{});
                    std.debug.print("      Snapshot: {s}\n", .{restore_snap.*});
                    std.debug.print("      Target disk: {s}\n", .{restore_disk.*});
                }
            }
        }
    }
    // Storage commands
    else if (storage_cmd.happened) {
        std.debug.print("=== OBJECT STORAGE MANAGEMENT ===\n", .{});
        
        if (buckets_cmd.happened) {
            std.debug.print("→ Managing Storage Buckets\n", .{});
            
            if (bucket_create_cmd.happened) {
                std.debug.print("  → Creating bucket: {s}\n", .{bucket_name.*});
                std.debug.print("    Location: {s}\n", .{bucket_location.*});
                if (bucket_versioning.*) {
                    std.debug.print("    Versioning: ENABLED\n", .{});
                }
            } else if (objects_cmd.happened) {
                std.debug.print("  → Object Management\n", .{});
                
                if (obj_upload_cmd.happened) {
                    std.debug.print("    → Uploading object\n", .{});
                    std.debug.print("      File: {s}\n", .{upload_file.*});
                    std.debug.print("      Bucket: {s}\n", .{upload_bucket.*});
                    if (upload_public.*) {
                        std.debug.print("      Visibility: PUBLIC\n", .{});
                    }
                }
            }
        }
    }
    // Database commands
    else if (database_cmd.happened) {
        std.debug.print("=== DATABASE SERVICE MANAGEMENT ===\n", .{});
        
        if (sql_cmd.happened) {
            std.debug.print("→ SQL Database Management\n", .{});
            
            if (db_instances_cmd.happened) {
                std.debug.print("  → Managing Database Instances\n", .{});
                
                if (db_create_cmd.happened) {
                    std.debug.print("    → Creating database instance: {s}\n", .{db_name.*});
                    std.debug.print("      Tier: {s}\n", .{db_tier.*});
                    if (db_ha.*) {
                        std.debug.print("      High Availability: ENABLED\n", .{});
                    }
                } else if (db_backups_cmd.happened) {
                    std.debug.print("    → Backup Management\n", .{});
                    
                    if (backup_create_cmd.happened) {
                        std.debug.print("      → Creating manual backup\n", .{});
                        std.debug.print("        Instance: {s}\n", .{backup_inst.*});
                        if (backup_desc.*.len > 0) {
                            std.debug.print("        Description: {s}\n", .{backup_desc.*});
                        }
                    }
                }
            }
        }
    }
}