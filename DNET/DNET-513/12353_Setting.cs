using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace OurApp
{
    [Table("CONFIGURATION")]
    public class Setting
    {

        [Key, Column("CONFIGKEY")]
        [StringLength(128)]
        public string Key { get; set; }

        [Column("CONFIGVALUE")]
        [StringLength(200)]
        public string Value { get; set; }
		
    }

}
