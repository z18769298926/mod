{include file='admin/main.tpl'}

<main class="content">
	<div class="content-header ui-content-header">
		<div class="container">
			<h1 class="content-heading">用户列表</h1>
		</div>
	</div>
	<div class="container">
		<div class="col-lg-12 col-sm-12">
			<section class="content-inner margin-top-no">

				<div class="card">
					<div class="card-main">
						<div class="card-inner">
							<p>系统中所有用户的列表。</p>
							<p>显示表项:
                {include file='table/checkbox.tpl'}
              </p>
						</div>
					</div>
				</div>

				<div class="table-responsive">
					{include file='table/table.tpl'}
				</div>

				<div class="card">
					<div class="card-main">
						<div class="card-inner">
							<h3 style='font-family: "Microsoft YaHei"'>添加用户</h3></p>
							<div class="form-group form-group-label col-md-12">
								<label class="floating-label" for="userName" style="padding-left: 20px">用户名</label>
								<input class="form-control" id="userName" type="text">
							</div>
							<div class="form-group form-group-label col-md-12">
								<label class="floating-label" for="sptype" style="padding-left: 20px">选择您要开通的套餐</label>
								<select class="form-control" id="sptype">
									<option></option>
                                    {foreach $shop_name as $key => $value}
										<option value="{$value["id"]}">{$value["name"]}</option>
                                    {/foreach}
								</select>
							</div>
							<a class="btn btn-brand" href="javascript:void(0)" id="add_input" style="margin-left: 20px">确定添加</a>
						</div>
					</div>
				</div>

				<div aria-hidden="true" class="modal modal-va-middle fade" id="delete_modal" role="dialog" tabindex="-1">
					<div class="modal-dialog modal-xs">
						<div class="modal-content">
							<div class="modal-heading">
								<a class="modal-close" data-dismiss="modal">×</a>
								<h2 class="modal-title">确认要删除？</h2>
							</div>
							<div class="modal-inner">
								<p>请您确认。</p>
							</div>
							<div class="modal-footer">
								<p class="text-right"><button class="btn btn-flat btn-brand-accent waves-attach waves-effect" data-dismiss="modal" type="button">取消</button><button class="btn btn-flat btn-brand-accent waves-attach" data-dismiss="modal" id="delete_input" type="button">确定</button></p>
							</div>
						</div>
					</div>
				</div>

				{include file='dialog.tpl'}


		</div>



	</div>
</main>






{include file='admin/footer.tpl'}

<script>
function delete_modal_show(id) {
	deleteid=id;
	$("#delete_modal").modal();
}

{include file='table/js_1.tpl'}

$(document).ready(function(){
 	table_1 = $('#table_1').DataTable({
			"stateSave": true,
			"columnDefs": [
				{
						targets: [ '_all' ],
						className: 'mdl-data-table__cell--non-numeric'
				}
			],
			{include file='table/lang_chinese.tpl'}
  });

	var has_init = JSON.parse(localStorage.getItem(window.location.href + '-hasinit'));
	if (has_init != true) {
	    localStorage.setItem(window.location.href + '-hasinit', true);
	} else {
	    {foreach $table_config['total_column'] as $key => $value}
	        var checked = JSON.parse(localStorage.getItem(window.location.href + '-haschecked-checkbox_{$key}'));
	        if (checked == true) {
	            document.getElementById('checkbox_{$key}').checked = true;
	        } else {
	            document.getElementById('checkbox_{$key}').checked = false;
	        }
	    {/foreach}
	}

	{foreach $table_config['total_column'] as $key => $value}
	  modify_table_visible('checkbox_{$key}', '{$key}');
	{/foreach}

	function delete_id(){
		$.ajax({
			type:"DELETE",
			url:"/admin/user",
			dataType:"json",
			data:{
				id: deleteid
			},
			success:function(data){
				if(data.ret){
					$("#result").modal();
					$("#msg").html(data.msg);
					{include file='table/js_delete.tpl'}
				}else{
					$("#result").modal();
					$("#msg").html(data.msg);
				}
			},
			error:function(jqXHR){
				$("#result").modal();
				$("#msg").html(data.msg+"  发生错误了。");
			}
		});
	}

    function addUser() {
        var name = document.getElementById("userName").value;
        var shopId = document.getElementById("sptype").value;
        if (name == ""){
            $("#result").modal();
            $("#msg").html("请填写用户名！");
            return;
        }
        if (shopId == ""){
            $("#result").modal();
            $("#msg").html("请选择套餐！");
            return;
        }
        $.ajax({
            type: "POST",
            url: "/admin/user/add",
            dataType: "json",
            data: {
                "userName": name,
                "shopId": shopId
            },
            success: function (data) {
                if (data.ret) {
                    $("#result").modal();
                    $("#msg").html(data.msg);

                    setTimeout("location.href='/admin/user'",1000);

                } else {
                    $("#result").modal();
                    $("#msg").html(data.msg);
                }
            },
            error: function (jqXHR) {
                $("#result").modal();
                $("#msg").html(data.msg + "  发生错误了。");
            }
        });
    }

    $("#add_input").click(function () {
        addUser();
    });


    $("#delete_input").click(function(){
		delete_id();
	});



	$("#search_button").click(function(){
		if($("#search").val()!="")
		{
			search();
		}
	});

	$.ajaxSettings.async = false;
	page = 1;
	while (1) {
			next = 1;
			$.getJSON("user/ajax?page=" + page, function( data ) {
					if (data.next == 0) {
							next = 0;
					}
					for ( var i=0, ien=data.data.length ; i<ien ; i++ ) {
						data.data[i][0] = '<a class="btn btn-brand" href="/admin/user/' + data.data[i][0] + '/edit">编辑</a>' +
						'<a class="btn btn-brand-accent" id="delete" href="javascript:void(0);" onClick="delete_modal_show(\'' + data.data[i][0] + '\')">删除</a>';
					}
					table_1.rows.add(data.data).draw();
			});

			if (next == 0) break;

			page++;
	}
	$.ajaxSettings.async = true;
})


</script>
